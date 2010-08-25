namespace :deploy do
  namespace :db do
    set(:properties) { ::YAML.load_file("config/database.yml")[stage.to_s] }

    task :backup, :roles => :db do
      on_rollback { run "mysql -u #{properties['username']} -p#{properties['password']} #{properties['database']} < #{previous_release}/dump.sql" rescue nil }
      run "mysqldump -u #{properties['username']} -p#{properties['password']} #{properties['database']} > #{previous_release}/dump.sql" rescue nil
    end

    task :setup, roles => :db do
      run "mysql -uroot -ppassword -e 'create database if not exists `#{properties['database']}`'"
    end
    
    task :teardown, roles => :db do
      run "mysql -uroot -ppassword -e 'drop database if exists `#{properties['database']}`'"
    end
  end

  # use mongrel_cluster rather than 'spin' script
  task :start, :roles => :app do
    run "#{deploy_to}/current/config/mongrel/mongrel_cluster restart #{deploy_to}/current/config/mongrel/#{stage}"
  end

  task :stop, :roles => :app do
    run "#{deploy_to}/current/config/mongrel/mongrel_cluster stop #{deploy_to}/current/config/mongrel/#{stage}"
  end
  
  task :restart, :roles => :app do
    deploy.start
  end

  task :geminstaller, :roles => :app do
    sudo "geminstaller -c #{current_release}/config/geminstaller.yml"
  end

  task :asset_packager, :role => :web do
    run "cd #{current_release} && rake RAILS_ENV=#{stage} asset:packager:build_all"
  end

  task :transactional do
    transaction { migrations }
  end
  
  # version.txt is a file that, using a subversion keyword, indicates the repository of the current release.
  task :refresh_version_txt do
    version_txt_path = "#{strategy.send(:repository_cache)}/public/version.txt"
    run "rm #{version_txt_path} && svn up -q --username build --password v0posl6m2 --no-auth-cache #{version_txt_path}"
    run "cp #{version_txt_path} #{current_release}/public/version.txt"
  end

  task :default do
    deploy.transactional
  end
end

task :deploy_for_cc do
  deploy.setup
  deploy.transactional
end

namespace :svn do
  task :cut_for_cc, :role => :app do
    cut_without_warning
    puts "created tag #{tag}"
    File.open("#{cc_build_artifacts}/#{tag}", "w") {|f| f << tag }
  end

  task :cut, :role => :app do
    puts "are you sure you want to do a cut?  it will blow away any local changes."
    puts "type 'y' to do a cut"

    if $stdin.gets.chomp == 'y'
      cut_without_warning
    else
      puts "skipping cut"
    end
  end

  task :cut_without_warning, :role => :app do
    require_subversion_helper
    set :tag, run_subversion_task(SubversionHelper::SubversionTasks::Cut.new)
  end

  task :tag_externals, :role => :app do
    require_subversion_helper
    run_subversion_task SubversionHelper::SubversionTasks::TagExternals.new(tag)
  end

  task :copy_tag_including_externals, :role => :app do
    raise "from_tag and to_tag variables must be specified" unless from_tag && to_tag
    require_subversion_helper
    run_subversion_task SubversionHelper::SubversionTasks::CopyTagIncludingExternals.new(from_tag, to_tag)
  end

  task :freeze_externals_to_tag, :role => :app do
    require_subversion_helper
    run_subversion_task SubversionHelper::SubversionTasks::FreezeExternalsToTag.new(tag, plugin_group)
  end

  def require_subversion_helper
    dir = File.dirname(__FILE__)
    require "#{dir}/../no_framework_bootstrap"
    require "subversion_helper"
  end

  def run_subversion_task(task)
    task.application = application
    task.repository_base = repository_root
    task.run
  end
end
