class DbTasks
  ENVIRONMENTS = ['development', 'test']
  
  def initialize(rake)
    @rake = rake
  end

  def init
    ENVIRONMENTS.each do |env|
      init_with_environment(env)
    end
  end

  def init_with_environment(environment)
    config = get_database_config(environment)
    recreate_database(environment, config)
  end

  def setup
    init
    execute "rake db:fixtures:load RAILS_ENV=development"
  end

  def execute(cmd)
    puts "\t#{cmd}"
    unless system(cmd)
      puts "\tFailed with status #{$?.exitstatus}"
    end
  end

  def delete_data(environment)
    config = get_database_config(environment)

    puts "\nInitializing #{environment} database"
    database = config["database"]
    username = config["username"]
    password = config["password"]

    tables_data = `mysql -D #{database} -u#{username} -p#{password} -e "show tables;"`
    tables = tables_data.split("\n")[1..-1]
    tables.each do |table|
      execute "mysql -D #{database} -u#{username} -p#{password} -e 'TRUNCATE TABLE #{table};'"
    end
  end

  protected
  def get_database_config(environment)
    require "yaml"
    yaml_text = File.read("#{RAILS_ROOT}/config/database.yml")

    database_yaml = YAML.load(yaml_text)
    database_yaml[environment]
  end

  def recreate_database(environment, config)
    puts "\nInitializing #{environment} database"
    database = config["database"]
    username = config["username"]
    password = config["password"]
    sql = "drop database if exists #{database}; create database #{database} character set utf8;"
    cmd = %Q|mysql -u#{username} -p#{password} -e "#{sql}"|

    execute cmd

    #todo: encapsulate this tempfile rake invocation stuff
    puts "\nMigrating #{environment} database"
    # invoke rake, capturing output to a temp file
    migrate_cmd = "#{rake_command} db:migrate RAILS_ENV=#{environment} --trace 2>&1"
    puts "\t#{migrate_cmd}"
    output = `#{migrate_cmd}`
    # Windows doesn't return an exit code from rake.bat, so we have to grep for "rake aborted!"
    if (error_code? || output.include?("rake aborted!"))
      # print rake output only on failure
      puts "\nCommand: #{migrate_cmd.inspect} failed (status #{$?.exitstatus})"
      puts output
      raise("Migrating #{environment} database failed")
    end
    puts "Migrated #{environment} database successfully"
  end

  def file_contains(path, string)
    File.read(path).include?(string)
  end

  def system(cmd)
    @rake.send(:system, cmd)
  end

  def error_code?
    $?.exitstatus != 0
  end
end
