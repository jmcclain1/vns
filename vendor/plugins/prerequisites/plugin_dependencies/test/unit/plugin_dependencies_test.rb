require "#{File.dirname(__FILE__)}/../test_helper"

class PluginDependenciesTest < Test::Unit::TestCase
  def setup
    @initializer = PluginAWeek::PluginDependencies.initializer
  end
  
  def test_dependencies_loaded
    assert_equal ['first', 'second', 'third'], PluginAWeek::PluginDependencies.dependencies_loaded
  end
  
  def test_initializer_not_loaded
    PluginAWeek::PluginDependencies.initializer = nil
    assert_raise(MissingSourceFile) {require 'invalid_plugin'}
    assert_raise(PluginAWeek::PluginDependencies::InitializerNotLoaded) {require_plugin 'invalid_plugin'}
    assert_raise(PluginAWeek::PluginDependencies::InitializerNotLoaded) {plugin 'invalid_plugin'}
  end
  
  def test_missing_source_file
    assert_raise(MissingSourceFile) {require 'invalid_plugin'}
    assert_raise(MissingSourceFile) {require_plugin 'invalid_plugin'}
    assert_raise(MissingSourceFile) {plugin 'invalid_plugin'}
  end
  
  def test_exception_within_plugin_initialization
    assert_kind_of MissingSourceFile, PluginAWeek::PluginDependencies.plugin_exception_thrown
    assert_equal 'no such file to load -- invalid_plugin', PluginAWeek::PluginDependencies.plugin_exception_thrown.message
  end
  
  def teardown
    PluginAWeek::PluginDependencies.initializer = @initializer
  end
end
