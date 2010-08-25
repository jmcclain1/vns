require "#{File.dirname(__FILE__)}/../test_helper"

class InitializerTest < Test::Unit::TestCase
  def setup
    @load_path = $LOAD_PATH.clone
    @config = Rails::Configuration.new
    @initializer = Rails::Initializer.new(@config)
    PluginAWeek::PluginDependencies.initializer = @initializer
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
  
  def test_require_regular_gem
    require 'only_a_gem'
    assert_equal [], @initializer.loaded_plugin_paths
  end
  
  def test_require_gem_plugin
    require 'gem_plugin'
    assert_equal [gem_path('gem_plugin-1.1.0')], @initializer.loaded_plugin_paths
  end
  
  def test_require_gem_plugin_with_init
    require 'gem_plugin_with_init'
    assert_equal [gem_path('gem_plugin_with_init-0.0.1')], @initializer.loaded_plugin_paths
  end
  
  def test_require_gem_with_dependencies
    require 'gem_with_dependencies'
    expected = [
      gem_path('gem_with_dependencies-0.1.0'),
      gem_path('dependent_gem_plugin-0.0.2-mswin32')
    ]
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_strict_require_gem_plugin_no_init
    assert_raise(MissingSourceFile) {plugin 'gem_plugin_with_lib', true}
  end
  
  def test_strict_require_gem_plugin_with_init
    plugin 'gem_plugin_with_init', true
    assert_equal [gem_path('gem_plugin_with_init-0.0.1')], @initializer.loaded_plugin_paths
  end
  
  def test_flexible_require_gem_plugin_with_no_init
    plugin 'gem_plugin_with_lib', false
    assert_equal [gem_path('gem_plugin_with_lib-1.0.1')], @initializer.loaded_plugin_paths
  end
  
  def test_flexible_require_gem_plugin_with_init
    plugin 'gem_plugin_with_init', false
    assert_equal [gem_path('gem_plugin_with_init-0.0.1')], @initializer.loaded_plugin_paths
  end
  
  def teardown
    $LOAD_PATH.replace(@load_path)
  end
end