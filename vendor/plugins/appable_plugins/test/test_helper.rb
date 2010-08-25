# Load the environment
ENV['RAILS_ENV'] ||= 'test'
require File.dirname(__FILE__) + '/rails_root/config/environment.rb'

# Load the testing framework
require 'test/unit'

# Simulate a custom gem being in the load path
$:.unshift("#{RAILS_ROOT}/vendor/gem_home/gems/graph_nodes/lib")

class Test::Unit::TestCase
  private
  def app_root
    "#{RAILS_ROOT}/app"
  end
  
  def plugins_root
    "#{RAILS_ROOT}/vendor/plugins"
  end
  
  def plugins(name)
    instance_variable_get("@#{name}_plugin") || instance_variable_set("@#{name}_plugin", Rails.plugins[name].clone)
  end
  
  def transaction(include_load_path = false)
    mixable_app_types = Plugin.mixable_app_types
    load_path_cache = Dependencies.load_path_cache
    load_once_paths = Dependencies.load_once_paths
    load_paths = Dependencies.load_paths
    controller_paths = ActionController::Routing.controller_paths
    
    if include_load_path
      load_path = $LOAD_PATH.clone
      $LOAD_PATH.clear
      $LOAD_PATH << '.'
    end
    
    Plugin.mixable_app_types = {
      :controllers => /.+_controller/,
      :helpers => /.+_helper/,
      :models => /.+/
    }
    Dependencies.load_path_cache = {}
    Dependencies.load_once_paths = []
    Dependencies.load_paths = []
    ActionController::Routing.controller_paths = []
    
    yield
  ensure
    Plugin.mixable_app_types = mixable_app_types
    Dependencies.load_path_cache = load_path_cache
    Dependencies.load_once_paths = load_once_paths
    Dependencies.load_paths = load_paths
    ActionController::Routing.controller_paths = controller_paths
    
    if include_load_path
      $LOAD_PATH.clear
      $LOAD_PATH.concat(load_path)
    end
  end
end