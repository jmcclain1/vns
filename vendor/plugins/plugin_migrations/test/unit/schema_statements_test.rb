require "#{File.dirname(__FILE__)}/../test_helper"

class SchemaStatementsTest < Test::Unit::TestCase
  def test_schema_info_table
    assert !PluginSchemaInfo.table_exists?
  end
  
  def test_initialize_schema_information_already_initialized
    initialize_schema_information
    assert PluginSchemaInfo.table_exists?
  end
  
  def test_dump_schema_info_with_no_plugin_schema_info
    assert_equal '', ActiveRecord::Base.connection.dump_schema_information
  end
  
  def test_dump_schema_info_with_no_version
    initialize_schema_information
    PluginSchemaInfo.create(:plugin_name => 'test_plugin', :version => 0)
    assert_equal '', ActiveRecord::Base.connection.dump_schema_information
  end
  
  def test_dump_schema_info
    initialize_schema_information
    PluginSchemaInfo.create(:plugin_name => 'test_plugin', :version => 1)
    assert_equal "INSERT INTO plugin_schema_info (plugin_name, version) VALUES ('test_plugin', 1)", ActiveRecord::Base.connection.dump_schema_information
  end
  
  def test_dump_schema_info_multiple_plugins
    initialize_schema_information
    PluginSchemaInfo.create(:plugin_name => 'test_plugin', :version => 1)
    PluginSchemaInfo.create(:plugin_name => 'another_plugin', :version => 2)
    
    expected = [
      "INSERT INTO plugin_schema_info (plugin_name, version) VALUES ('test_plugin', 1);",
      "INSERT INTO plugin_schema_info (plugin_name, version) VALUES ('another_plugin', 2)"
    ].join("\n")
    assert_equal expected, ActiveRecord::Base.connection.dump_schema_information
  end
  
  def test_dump_schema_info_with_regular_schema_info
    initialize_schema_information
    ActiveRecord::Base.connection.update("UPDATE #{ActiveRecord::Migrator.schema_info_table_name} SET version = 1")
    PluginSchemaInfo.create(:plugin_name => 'test_plugin', :version => 1)
    
    expected = [
      'INSERT INTO schema_info (version) VALUES (1);',
      "INSERT INTO plugin_schema_info (plugin_name, version) VALUES ('test_plugin', 1)"
    ].join("\n")
    assert_equal expected, ActiveRecord::Base.connection.dump_schema_information
  end
  
  def test_dump_schema_info_only_regular_schema_info
    initialize_schema_information
    ActiveRecord::Base.connection.update("UPDATE #{ActiveRecord::Migrator.schema_info_table_name} SET version = 1")
    assert_equal 'INSERT INTO schema_info (version) VALUES (1)', ActiveRecord::Base.connection.dump_schema_information
  end
  
  def teardown
    ActiveRecord::Base.connection.drop_table(SchemaInfo.table_name) if SchemaInfo.table_exists?
    ActiveRecord::Base.connection.drop_table(PluginSchemaInfo.table_name) if PluginSchemaInfo.table_exists?
  end
end