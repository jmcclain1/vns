require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PluginListTest < Test::Unit::TestCase
  def setup
    @plugin_list = PluginList.new
    @plugin_list << (@plugin = Plugin.new('/path/to/plugin'))
    @plugin_list << (@another_plugin = Plugin.new('/path/to/another_plugin'))
  end
  
  def test_access_by_index
    assert_equal @plugin, @plugin_list[0]
    assert_equal @another_plugin, @plugin_list[1]
  end
  
  def test_access_by_name
    assert_equal @plugin, @plugin_list[:plugin]
    assert_equal @plugin, @plugin_list['plugin']
  end
  
  def test_find_by_names
    assert_equal @plugin_list, @plugin_list.find_by_names
    assert_equal [@plugin], @plugin_list.find_by_names('plugin')
    assert_equal [@plugin, @another_plugin], @plugin_list.find_by_names('plugin,another_plugin')
  end
  
  def test_find_by_names_on_empty_list
    assert_equal [], PluginList.new.find_by_names
  end
  
  def test_get_invalid_plugin_paths
    assert_raise(RuntimeError) {@plugin_list.find_by_names('invalid_plugin')}
  end
  
  def test_get_invalid_plugin_paths_with_valid_paths_too
    assert_raise(RuntimeError) {@plugin_list.find_by_names('plugin,invalid_plugin,another_plugin')}
  end
  
  def test_by_precedence
    assert_equal @plugin_list.reverse, @plugin_list.by_precedence
  end
end