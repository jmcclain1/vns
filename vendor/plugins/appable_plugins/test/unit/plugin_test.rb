require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class Plugin
  public  :inject_controller_paths,
          :add_to_load_path,
          :add_to_dependency_load_paths
end

class PluginTest < Test::Unit::TestCase
  def setup
    @actor_skeleton = Plugin.new("#{plugins_root}/actor_skeleton")
    @actor_skeleton_app_paths = [
      "#{@actor_skeleton.root}/app",
      "#{@actor_skeleton.root}/app/controllers",
      "#{@actor_skeleton.root}/app/models"
    ]
    
    @loaded_plugins = Rails.plugins
    Rails.plugins = [@actor_skeleton]
  end
  
  def test_mixable_app_types
    expected = {
      :apis => /.+_api/,
      :controllers => /.+_controller|application/,
      :helpers => /.+_helper/,
      :mailers => /.+/,
      :models => /.+/,
      :services => /.+_service/
    }
    assert_equal expected, Plugin.mixable_app_types
  end
  
  def test_enable_code_mixing
    assert @actor_skeleton.enable_code_mixing?
    
    @actor_skeleton.enable_code_mixing = false
    assert !@actor_skeleton.enable_code_mixing?
  end
  
  def test_app_path
    assert_equal "#{@actor_skeleton.root}/app", @actor_skeleton.app_path
  end
  
  def test_controllers_path
    assert_equal "#{@actor_skeleton.root}/app/controllers", @actor_skeleton.controllers_path
  end
  
  def test_load_paths
    assert_equal @actor_skeleton_app_paths, @actor_skeleton.load_paths
  end
  
  def test_load_paths_no_app_path
    plugin = Plugin.new("#{plugins_root}/appable_plugins")
    assert_equal [], plugin.load_paths
  end
  
  def test_load_paths_with_non_standard_paths
    plugin_root = "#{plugins_root}/mailer_skeleton"
    plugin = Plugin.new(plugin_root)
    
    expected = [
      "#{plugin_root}/app",
      "#{plugin_root}/app/mailers"
    ]
    assert_equal expected, plugin.load_paths
  end
  
  def test_before_load_injects_dependencies
    transaction(true) do
      @actor_skeleton.before_load
      
      assert_equal ['.'] + @actor_skeleton_app_paths + [@actor_skeleton.lib_path], $LOAD_PATH
      assert_equal @actor_skeleton_app_paths, Dependencies.load_paths
    end
  end
  
  def test_after_load_removes_duplicate_lib_path
    transaction(true) do
      @actor_skeleton.inject_dependencies
      $LOAD_PATH.unshift(@actor_skeleton.lib_path)
      assert_equal [@actor_skeleton.lib_path, '.'] + @actor_skeleton_app_paths + [@actor_skeleton.lib_path], $LOAD_PATH
      
      @actor_skeleton.after_load
      assert_equal ['.'] + @actor_skeleton_app_paths + [@actor_skeleton.lib_path], $LOAD_PATH
    end
  end
  
  def test_after_load_doesnt_remove_lib_path_if_no_lib_path
    plugin = Plugin.new(@actor_skeleton.lib_path)
    Rails.plugins << plugin
    
    transaction(true) do
      plugin.inject_dependencies
      $LOAD_PATH.unshift(plugin.lib_path)
      assert_equal [plugin.lib_path, '.'], $LOAD_PATH
      
      plugin.after_load
      assert_equal [plugin.lib_path, '.'], $LOAD_PATH
    end
  end
  
  def test_after_load_doesnt_remove_lib_path_if_no_dependencies_inject
    transaction(true) do
      $LOAD_PATH.unshift(@actor_skeleton.lib_path)
      assert_equal [@actor_skeleton.lib_path, '.'], $LOAD_PATH
      
      @actor_skeleton.after_load
      assert_equal [@actor_skeleton.lib_path, '.'], $LOAD_PATH
    end
  end
  
  def test_after_initialize
    transaction(true) do
      @actor_skeleton.after_initialize
      assert_equal ["#{@actor_skeleton.root}/app/controllers"], ActionController::Routing.controller_paths
      assert_equal ['.'] + @actor_skeleton_app_paths, $LOAD_PATH
    end
  end
  
  def test_inject_dependencies
    transaction(true) do
      3.times do
        @actor_skeleton.inject_dependencies
        
        assert_equal ['.'] + @actor_skeleton_app_paths + [@actor_skeleton.lib_path], $LOAD_PATH
        assert_equal @actor_skeleton_app_paths, Dependencies.load_paths
      end
    end
  end
  
  def test_inject_controller_paths
    transaction do
      @actor_skeleton.inject_controller_paths
      assert_equal ["#{@actor_skeleton.root}/app/controllers"], ActionController::Routing.controller_paths
    end
  end
  
  def test_inject_controller_paths_no_controllers
    plugin = Plugin.new("#{plugins_root}/appable_plugins")
    
    transaction do
      plugin.inject_controller_paths
      assert_equal [], ActionController::Routing.controller_paths
    end
  end
  
  def test_find_file_exists
    assert_equal "#{@actor_skeleton.root}/app/models/actor.rb", @actor_skeleton.find_file('models/actor.rb')
  end
  
  def test_find_file_nonexistent
    assert_nil @actor_skeleton.find_file('models/fake.rb')
  end
  
  def test_find_file_exists_but_code_mixing_disabled
    @actor_skeleton.enable_code_mixing = false
    assert_nil @actor_skeleton.find_file('models/actor.rb')
  end
  
  def test_add_to_load_path
    transaction(true) do
      $LOAD_PATH.concat([
        Rails.lib_path,
        'after'
      ])
      
      expected = [
        '.',
        Rails.lib_path
      ] + @actor_skeleton_app_paths + [
        @actor_skeleton.lib_path,
        'after'
      ]
      
      @actor_skeleton.add_to_load_path(:before_load)
      assert_equal expected, $LOAD_PATH
    end
  end
  
  def test_add_to_load_path_no_rails_lib_path
    transaction(true) do
      $LOAD_PATH.concat([
        'after'
      ])
      
      expected = [
        '.'
      ] + @actor_skeleton_app_paths + [
        @actor_skeleton.lib_path,
        'after'
      ]
      
      @actor_skeleton.add_to_load_path(:before_load)
      assert_equal expected, $LOAD_PATH
    end
  end
  
  def test_add_to_load_path_already_loaded
    transaction(true) do
      $LOAD_PATH.concat([
        Rails.lib_path,
        'after_rails_lib',
        @actor_skeleton.lib_path,
        'after_plugin_lib'
      ])
      
      expected = [
        '.',
        Rails.lib_path,
        'after_rails_lib',
      ] + @actor_skeleton_app_paths + [
        @actor_skeleton.lib_path,
        'after_plugin_lib'
      ]
      
      @actor_skeleton.add_to_load_path(:after_initialize)
      assert_equal expected, $LOAD_PATH
    end
  end
  
  def test_add_to_load_path_already_loaded_no_lib_path
    plugin = Plugin.new("#{plugins_root}/agent_skeleton")
    Rails.plugins << plugin
    Rails.plugins << Plugin.new("#{plugins_root}/second_actor_skeleton")
    
    transaction(true) do
      $LOAD_PATH.concat([
        Rails.lib_path,
        'after_rails_lib',
        @actor_skeleton.lib_path,
        'after_plugin_lib'
      ])
      
      expected = [
        '.',
        Rails.lib_path,
        "#{plugin.root}/app",
        "#{plugin.root}/app/models",
        'after_rails_lib',
        @actor_skeleton.lib_path,
        'after_plugin_lib'
      ]
      
      plugin.add_to_load_path(:after_initialize)
      assert_equal expected, $LOAD_PATH
    end
  end
  
  def test_add_to_load_path_already_loaded_no_lib_path_no_plugins_before_with_load_paths
    plugin = Plugin.new("#{plugins_root}/agent_skeleton")
    Rails.plugins << plugin
    Rails.plugins << Plugin.new("#{plugins_root}/second_actor_skeleton")
    
    transaction(true) do
      $LOAD_PATH.concat([
        Rails.lib_path,
        'after_plugin_lib'
      ])
      
      expected = [
        '.',
        Rails.lib_path,
        "#{plugin.root}/app",
        "#{plugin.root}/app/models",
        'after_plugin_lib'
      ]
      
      plugin.add_to_load_path(:after_initialize)
      assert_equal expected, $LOAD_PATH
    end
  end
  
  def test_add_to_dependency_load_paths
    transaction do
      @actor_skeleton.add_to_dependency_load_paths(:before_load)
      assert_equal @actor_skeleton_app_paths, Dependencies.load_paths
    end
  end
  
  def test_add_to_dependency_load_paths_no_load_paths
    plugin = Plugin.new("#{plugins_root}/appable_plugins")
    Rails.plugins << plugin
    
    transaction do
      plugin.add_to_dependency_load_paths(:before_load)
      assert_equal [], Dependencies.load_paths
    end
  end
  
  def teardown
    Rails.plugins = @loaded_plugins
  end
end