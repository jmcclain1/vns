require "#{File.dirname(__FILE__)}/../test_helper"

class Rails::Initializer
  public  :find_plugins,
          :load_plugins,
          :plugin_name,
          :find_plugin,
          :find_plugin_in_application,
          :find_plugin_in_gems
end

class InitializerTest < Test::Unit::TestCase
  def setup
    @load_path = $LOAD_PATH.clone
    @config = Rails::Configuration.new
    @initializer = Rails::Initializer.new(@config)
    PluginAWeek::PluginDependencies.initializer = @initializer
  end
  
  def test_load_plugins_no_plugins_configured
    @config.plugins = nil
    assert_equal vendor_plugins, @initializer.find_plugins(plugins_path).sort
    
    @initializer.load_plugins
    expected = [
      plugin_path('a_plugin_with_dependencies'),
      plugin_path('first_plugin'),
      plugin_path('second_plugin'),
      plugin_path('third_plugin'),
      plugin_path('plugin_with_exception')
    ]
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_empty_plugins_configured
    @config.plugins = []
    assert_equal [], @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    assert_equal [], @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_all_plugins_configured
    @config.plugins = %w(first_plugin second_plugin third_plugin)
    
    expected = @config.plugins.collect {|name| plugin_path(name)}
    assert_equal expected, @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_with_gems_configured
    @config.plugins = [
      'first_plugin',
      'gem_plugin_with_init',
      'gem_plugin_with_lib'
    ]
    
    expected = [
      plugin_path('first_plugin'),
      gem_path('gem_plugin_with_init-0.0.1'),
      gem_path('gem_plugin_with_lib-1.0.1')
    ]
    assert_equal expected, @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_with_duplicate_gem_and_plugin_names
    @config.plugins = [
      'first_plugin'
    ]
    
    expected = [plugin_path('first_plugin')]
    assert_equal expected, @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_with_gem_version_requirements
    @config.plugins = [
      'first_plugin',
      ['gem_plugin', '= 1.0.0'],
      ['gem_plugin_with_lib', '>= 1.0.0']
    ]
    
    expected = [
      plugin_path('first_plugin'),
      gem_path('gem_plugin-1.0.0'),
      gem_path('gem_plugin_with_lib-1.0.1')
    ]
    assert_equal expected, @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugins_with_unmet_gem_version_requirements
    @config.plugins = [
      ['gem_plugin', '>= 1.1.1']
    ]
    assert_equal [], @initializer.find_plugins(plugins_path)
    
    assert_raise(LoadError) {@initializer.load_plugins}
  end
  
  def test_load_plugins_with_gem_dependencies
    @config.plugins = [
      'gem_with_dependencies'
    ]
    assert_equal [gem_path('gem_with_dependencies-0.1.0')], @initializer.find_plugins(plugins_path)
    
    @initializer.load_plugins
    expected = [
      gem_path('gem_with_dependencies-0.1.0'),
      gem_path('dependent_gem_plugin-0.0.2-mswin32')
    ]
    assert_equal expected, @initializer.loaded_plugin_paths
  end
  
  def test_load_plugin_tasks
    require 'rake'
    
    @config.plugins = [
      'gem_plugin_with_tasks'
    ]
    @initializer.load_plugins
    
    assert_not_nil Rake::Task['db:bootstrap']
    assert_not_nil Rake::Task['do_stuff']
  end
  
  def test_plugin_name
    [
      'plugin_xyz',
      'plugin_xyz-1.2',
      'plugin_xyz-1.2.0',
      'plugin_xyz-1.2.0-mswin32'
    ].each do |name|
      assert_equal 'plugin_xyz', @initializer.plugin_name(name)
    end
  end
  
  def test_find_plugin_application_plugin
    assert_equal plugin_path('a_plugin_with_dependencies'), @initializer.find_plugin('a_plugin_with_dependencies')
  end
  
  def test_find_plugin_gem_plugin
    assert_equal gem_path('gem_plugin-1.1.0'), @initializer.find_plugin('gem_plugin')
  end
  
  def test_find_plugin_version_requirements
    assert_equal gem_path('gem_plugin-1.0.0'), @initializer.find_plugin('gem_plugin', :version => '<= 1.0.0')
    assert_equal gem_path('gem_plugin-1.1.0'), @initializer.find_plugin('gem_plugin', :version => '> 1.0.0')
  end
  
  def test_find_plugin_strict_gem_search
    assert_nil @initializer.find_plugin('only_a_gem', :strict => true)
    assert_nil @initializer.find_plugin('gem_plugin_with_lib', :strict => true)
    assert_equal gem_path('gem_plugin_with_init-0.0.1'), @initializer.find_plugin('gem_plugin_with_init', :strict => true)
  end
  
  
  def test_find_plugin_nonexistent
    assert_nil @initializer.find_plugin('nonexistent')
  end
  
  def test_find_plugin_in_application
    assert_equal plugin_path('first_plugin'), @initializer.find_plugin_in_application('first_plugin')
  end
  
  def test_find_plugin_in_application_nonexistent
    assert_nil @initializer.find_plugin_in_application('nonexistent')
  end
  
  def test_find_plugin_in_gems
    assert_equal gem_path('gem_plugin-1.1.0'), @initializer.find_plugin_in_gems('gem_plugin')
  end
  
  def test_find_plugin_in_gems_meets_version_requirements
    assert_equal gem_path('gem_plugin-1.0.0'), @initializer.find_plugin_in_gems('gem_plugin', :version => '<= 1.0.1')
  end
  
  def test_find_plugin_in_gems_doesnt_meet_version_requirements
    assert_nil @initializer.find_plugin_in_gems('gem_plugin', :version => '>= 1.2.0')
  end
  
  def test_find_plugin_in_gems_flexible_search
    assert_equal gem_path('only_a_gem-1.0.0'), @initializer.find_plugin_in_gems('only_a_gem')
  end
  
  def test_find_plugin_in_gems_strict_search
    assert_nil @initializer.find_plugin_in_gems('only_a_gem', :strict => true)
  end
  
  def test_find_plugin_in_gems_nonexistent
    assert_nil @initializer.find_plugin_in_gems('nonexistent')
  end
  
  def teardown
    $LOAD_PATH.replace(@load_path)
  end
  
  private
  def vendor_plugins
    [
      :a_plugin_with_dependencies,
      :first_plugin,
      :plugin_with_exception,
      :second_plugin,
      :third_plugin
    ].collect {|name| plugin_path(name)}
  end
end