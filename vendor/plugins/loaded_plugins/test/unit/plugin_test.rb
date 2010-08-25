require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PluginTest < Test::Unit::TestCase
  def setup
    @plugin = Plugin.new('/path/to/plugin')
  end
  
  def test_root
    assert_equal '/path/to/plugin', @plugin.root
  end
  
  def test_root_with_trailing_slash
    assert_equal '/path/to/plugin', Plugin.new('/path/to/plugin/').root
  end
  
  def test_name
    assert_equal 'plugin', @plugin.name
  end
  
  def test_name_for
    [
      'plugin_xyz',
      'plugin_xyz-1.2',
      'plugin_xyz-1.2.0',
      'plugin_xyz-1.2.0-win32'
    ].each do |name|
      assert_equal 'plugin_xyz', Plugin.name_for(name)
    end
  end
  
  def test_initialize_uses_name_for
    plugin = Plugin.new('/path/to/plugin_xyz-1.2.0-win32')
    assert_equal 'plugin_xyz', plugin.name
  end
  
  def test_lib_path
    assert_equal '/path/to/plugin/lib', @plugin.lib_path
  end
  
  def test_lib_path?
    assert !@plugin.lib_path?
    assert Plugin.new(RAILS_ROOT).lib_path?
  end
  
  def test_plugins_before_first_plugin
    assert_equal [], Rails.plugins.first.plugins_before
  end
  
  def test_plugins_before_middle_plugin
    expected = [
      :a_plugin_with_dependencies,
      :dependent_plugin,
      :first_plugin,
      :loaded_plugins
    ].collect {|name| Rails.plugins[name]}
    
    assert_equal expected, Rails.plugins[:plugin_with_lib_and_init].plugins_before
  end
  
  def test_plugins_before_last_plugin
    assert_equal Rails.plugins[0..-2], Rails.plugins.last.plugins_before
  end
  
  def test_plugins_after_first_plugin
    assert_equal Rails.plugins[1..Rails.plugins.size-1], Rails.plugins.first.plugins_after
  end
  
  def test_plugins_after_middle_plugin
    expected = [
      :plugin_with_only_init,
      :plugin_with_only_lib,
      :second_plugins_dependency,
      :second_plugin_with_dependencies
    ].collect {|name| Rails.plugins[name]}
    
    assert_equal expected, Rails.plugins[:plugin_with_lib_and_init].plugins_after
  end
  
  def test_plugins_after_last_plugin
    assert_equal [], Rails.plugins.last.plugins_after
  end
  
  def test_plugin_equality
    assert @plugin == Plugin.new('/different/path/to/plugin')
  end
  
  def test_name_equality
    assert @plugin == 'plugin'
  end
end