require "#{File.dirname(__FILE__)}/../test_helper"

class PluginMigrationsTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Migration.verbose = true
    initialize_schema_information
  end
  
  def test_schema_info_table_name
    assert_equal 'plugin_schema_info', PluginAWeek::PluginMigrations::Migrator.schema_info_table_name
  end
  
  def test_schema_info_table_name_with_prefix
    ActiveRecord::Base.table_name_prefix = 'prefix_'
    assert_equal 'prefix_plugin_schema_info', PluginAWeek::PluginMigrations::Migrator.schema_info_table_name
  end
  
  def test_schema_info_table_name_with_suffix
    ActiveRecord::Base.table_name_suffix = '_suffix'
    assert_equal 'plugin_schema_info_suffix', PluginAWeek::PluginMigrations::Migrator.schema_info_table_name
  end
  
  def test_schema_info_table_name_with_prefix_and_suffix
    ActiveRecord::Base.table_name_prefix = 'prefix_'
    ActiveRecord::Base.table_name_suffix = '_suffix'
    assert_equal 'prefix_plugin_schema_info_suffix', PluginAWeek::PluginMigrations::Migrator.schema_info_table_name
  end
  
  def test_set_schema_version
    PluginAWeek::PluginMigrations::Migrator.current_plugin = Plugin.new('/path/to/test_plugin')
    assert_equal 0, PluginAWeek::PluginMigrations::Migrator.current_version
    assert_equal 0, PluginSchemaInfo.count
    
    PluginAWeek::PluginMigrations::Migrator.allocate.set_schema_version(0)
    assert_equal 0, PluginAWeek::PluginMigrations::Migrator.current_version
    assert_equal 1, PluginSchemaInfo.count
    
    PluginAWeek::PluginMigrations::Migrator.allocate.set_schema_version(1)
    assert_equal 1, PluginAWeek::PluginMigrations::Migrator.current_version
    assert_equal 1, PluginSchemaInfo.count
    
    plugin = PluginSchemaInfo.find_by_plugin_name('test_plugin')
    assert_not_nil plugin
    assert_equal 1, plugin.version
  end
  
  def test_migrate_all_plugins
    PluginAWeek::PluginMigrations.migrate
    
    assert Company.table_exists?
    assert Employee.table_exists?
    assert Author.table_exists?
    assert Article.table_exists?
    assert Comment.table_exists?
    
    assert_equal 2, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 2),
      PluginSchemaInfo.new(:plugin_name => 'second_plugin_with_migrations', :version => 3)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_migrate_all_plugins_specific_version
    PluginAWeek::PluginMigrations.migrate(nil, 3)
    
    assert Company.table_exists?
    assert Employee.table_exists?
    assert Author.table_exists?
    assert Article.table_exists?
    assert Comment.table_exists?
    
    assert_equal 2, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 2),
      PluginSchemaInfo.new(:plugin_name => 'second_plugin_with_migrations', :version => 3)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
    
    PluginAWeek::PluginMigrations.migrate(nil, 1)
    
    assert Company.table_exists?
    assert !Employee.table_exists?
    assert Author.table_exists?
    assert !Article.table_exists?
    assert !Comment.table_exists?
    
    assert_equal 2, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 1),
      PluginSchemaInfo.new(:plugin_name => 'second_plugin_with_migrations', :version => 1)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
    
    PluginAWeek::PluginMigrations.migrate(nil, 0)
    
    assert !Company.table_exists?
    assert !Employee.table_exists?
    assert !Author.table_exists?
    assert !Article.table_exists?
    assert !Comment.table_exists?
    
    assert_equal 2, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 0),
      PluginSchemaInfo.new(:plugin_name => 'second_plugin_with_migrations', :version => 0)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_migrate_specific_plugins
    PluginAWeek::PluginMigrations.migrate('plugin_with_migrations')
    
    assert Company.table_exists?
    assert Employee.table_exists?
    assert !Author.table_exists?
    assert !Article.table_exists?
    assert !Comment.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 2)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_migrate_specific_plugins_specific_version
    PluginAWeek::PluginMigrations.migrate('plugin_with_migrations', 1)
    
    assert Company.table_exists?
    assert !Employee.table_exists?
    assert !Author.table_exists?
    assert !Article.table_exists?
    assert !Comment.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 2)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
    
    PluginAWeek::PluginMigrations.migrate('plugin_with_migrations', 0)
    
    assert !Company.table_exists?
    assert !Employee.table_exists?
    assert !Author.table_exists?
    assert !Article.table_exists?
    assert !Comment.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 0)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_load_fixtures_all_plugins
    PluginAWeek::PluginMigrations.migrate
    PluginAWeek::PluginMigrations.load_fixtures
    
    assert_equal 1, Company.count
    assert_equal 2, Employee.count
    assert_equal 2, Author.count
    assert_equal 1, Article.count
  end
  
  def test_load_fixtures_all_plugins_specific_fixtures
    PluginAWeek::PluginMigrations.migrate
    PluginAWeek::PluginMigrations.load_fixtures(nil, 'companies,authors')
    
    assert_equal 1, Company.count
    assert_equal 0, Employee.count
    assert_equal 2, Author.count
    assert_equal 0, Article.count
  end
  
  def test_load_fixtures_specific_plugins
    PluginAWeek::PluginMigrations.migrate
    PluginAWeek::PluginMigrations.load_fixtures('plugin_with_migrations')
    
    assert_equal 1, Company.count
    assert_equal 2, Employee.count
    assert_equal 0, Author.count
    assert_equal 0, Article.count
  end
  
  def test_load_fixtures_specific_plugins_specific_fixtures
    PluginAWeek::PluginMigrations.migrate
    PluginAWeek::PluginMigrations.load_fixtures('plugin_with_migrations', 'companies')
    
    assert_equal 1, Company.count
    assert_equal 0, Employee.count
    assert_equal 0, Author.count
    assert_equal 0, Article.count
  end
  
  def teardown
    ActiveRecord::Base.table_name_prefix = ''
    ActiveRecord::Base.table_name_suffix = ''
    ActiveRecord::Base.connection.drop_table(ActiveRecord::Migrator.schema_info_table_name)
    [Article, Author, Comment, Company, Employee, PluginSchemaInfo].each do |model|
      ActiveRecord::Base.connection.drop_table(model.table_name) if model.table_exists?
    end
  end
end
