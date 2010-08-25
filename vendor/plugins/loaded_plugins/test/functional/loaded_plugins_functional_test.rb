require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class LoadedPluginsFunctionalTest < Test::Unit::TestCase
  def setup
    @plugin_root = "#{RAILS_ROOT}/vendor/plugins"
  end
  
  def test_loaded_plugins
    expected = [
      ['a_plugin_with_dependencies', "#{@plugin_root}/a_plugin_with_dependencies"],
      ['dependent_plugin', "#{@plugin_root}/dependent_plugin"],
      ['first_plugin', "#{@plugin_root}/first_plugin"],
      ['loaded_plugins', "#{@plugin_root}/loaded_plugins"],
      ['plugin_with_lib_and_init', "#{@plugin_root}/plugin_with_lib_and_init"],
      ['plugin_with_only_init', "#{@plugin_root}/plugin_with_only_init"],
      ['plugin_with_only_lib', "#{@plugin_root}/plugin_with_only_lib"],
      ['second_plugins_dependency', "#{@plugin_root}/second_plugins_dependency"],
      ['second_plugin_with_dependencies', "#{@plugin_root}/second_plugin_with_dependencies"]
    ]
    
    Rails.plugins.each_with_index do |plugin, index|
      assert_equal expected[index][0], plugin.name
      assert_equal expected[index][1], plugin.root
    end
  end
end