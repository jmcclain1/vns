require "#{File.dirname(__FILE__)}/../test_helper"

class PluginTest < Test::Unit::TestCase
  def setup
    @plugin = Plugin.new("#{RAILS_ROOT}/vendor/plugins/plugin_with_migrations")
    ActiveRecord::Migration.verbose = true
    initialize_schema_information
  end
  
  def test_migration_path
    assert_equal "#{RAILS_ROOT}/vendor/plugins/plugin_with_migrations/db/migrate", @plugin.migration_path
  end
  
  def test_migrate_to_latest_version
    @plugin.migrate
    
    assert Company.table_exists?
    assert Employee.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 2)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_migrate_to_specific_version
    @plugin.migrate(1)
    
    assert Company.table_exists?
    assert !Employee.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 1)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
    
    @plugin.migrate(0)
    
    assert !Company.table_exists?
    assert !Employee.table_exists?
    
    assert_equal 1, PluginSchemaInfo.count
    expected = [
      PluginSchemaInfo.new(:plugin_name => 'plugin_with_migrations', :version => 0)
    ]
    assert_equal expected, PluginSchemaInfo.find(:all)
  end
  
  def test_fixtures_path
    assert_equal "#{RAILS_ROOT}/vendor/plugins/plugin_with_migrations/test/fixtures", @plugin.fixtures_path
  end
  
  def test_fixtures_all
    expected = [
      "#{@plugin.fixtures_path}/companies.yml",
      "#{@plugin.fixtures_path}/employees.yml"
    ]
    assert_equal expected, @plugin.fixtures
  end
  
  def test_fixtures_specific
    assert_equal ["#{@plugin.fixtures_path}/companies.yml"], @plugin.fixtures('companies')
    
    expected = [
      "#{@plugin.fixtures_path}/companies.yml",
      "#{@plugin.fixtures_path}/employees.yml"
    ]
    assert_equal expected, @plugin.fixtures('companies,employees')
  end
  
  def test_load_fixtures_all
    @plugin.migrate
    @plugin.load_fixtures
    
    assert_equal 1, Company.count
    assert_equal 2, Employee.count
  end
  
  def test_load_fixtures_specific
    @plugin.migrate
    @plugin.load_fixtures('companies')
    
    assert_equal 1, Company.count
    assert_equal 0, Employee.count
  end
  
  def teardown
    ActiveRecord::Base.connection.drop_table(ActiveRecord::Migrator.schema_info_table_name)
    [Company, Employee, PluginSchemaInfo].each do |model|
      ActiveRecord::Base.connection.drop_table(model.table_name) if model.table_exists?
    end
  end
end