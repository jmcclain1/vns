require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class Rails::Initializer
  public  :find_plugin_path,
          :plugins_to_load
end

class LoadedPluginsTest < Test::Unit::TestCase
  def test_find_plugin_path
    assert_equal "#{RAILS_ROOT}/vendor/plugins/first_plugin", Rails.initializer.find_plugin_path('first_plugin')
  end
  
  def test_find_plugin_path_nonexistent
    assert_nil Rails.initializer.find_plugin_path('nonexistent_plugin')
  end
  
  def test_plugins_to_load_all_plugins
    expected = [
      'a_plugin_with_dependencies',
      'dependent_plugin',
      'first_plugin',
      'loaded_plugins',
      'plugin_with_lib_and_init',
      'plugin_with_only_init',
      'plugin_with_only_lib',
      'second_plugin_with_dependencies',
      'second_plugins_dependency',
      'subfolder/plugin_with_lib_and_init'
    ].collect {|name| "#{RAILS_ROOT}/vendor/plugins/#{name}"}
    assert_equal expected, Rails.initializer.plugins_to_load
  end
  
  def test_plugins_to_load_manual
    Rails.initializer.configuration.plugins = [
      'first_plugin',
      'plugin_with_only_init',
      'plugin_with_only_lib'
    ]
    expected = Rails.initializer.configuration.plugins.collect {|name| "#{RAILS_ROOT}/vendor/plugins/#{name}"}
    assert_equal expected, Rails.initializer.plugins_to_load
  end
  
  def teardown
    Rails.initializer.configuration.plugins = nil
  end
end