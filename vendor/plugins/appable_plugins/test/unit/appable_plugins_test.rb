require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module PluginAWeek::AppablePlugins
  module_function :map_application_namespaces
end

class AppablePluginsTest < Test::Unit::TestCase
  def test_map_application_namespaces
    transaction do
      root = Rails.plugins[:second_actor_skeleton].root
      path = "#{root}/models"
      type = 'models'
      paths_to_skip = ["#{path}/admin"]
      base_directory = ''
      
      PluginAWeek::AppablePlugins.map_application_namespaces(path, type, paths_to_skip, base_directory)
      assert_equal ({}), Dependencies.app_namespaces
    end
  end
  
  def test_map_application_namespaces_none
    transaction do
      root = Rails.plugins[:second_actor_skeleton].root
      path = "#{root}/models/admin"
      type = 'models'
      paths_to_skip = ["#{root}/models"]
      base_directory = 'admin'
      
      PluginAWeek::AppablePlugins.map_application_namespaces(path, type, paths_to_skip, base_directory)
      assert_equal ({'models' => {'admin' => ''}}), Dependencies.app_namespaces
    end
  end
end