# Load the environment
ENV['RAILS_ENV'] ||= 'test'
require File.dirname(__FILE__) + '/rails_root/config/environment.rb'

# Load plugin_dependencies
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib"
require "#{File.dirname(__FILE__)}/../init"

# Load the testing framework
require 'test/unit'

# Set the gem path
Gem.use_paths("#{RAILS_ROOT}/vendor/gem_home")

# Add plugin tracking
class Rails::Initializer
  attr_accessor :loaded_plugin_paths
  
  def initialize_with_tracking(configuration)
    self.loaded_plugin_paths = []
    initialize_without_tracking(configuration)
  end
  alias_method_chain :initialize, :tracking
  
  def load_plugin_with_tracking(directory)
    self.loaded_plugin_paths << directory if !loaded_plugins.include?(File.basename(directory))
    load_plugin_without_tracking(directory)
  end
  alias_method_chain :load_plugin, :tracking
end

# Helper methods
class Test::Unit::TestCase
  protected
  def plugins_path
    "#{RAILS_ROOT}/vendor/plugins"
  end
  
  def gems_path
    "#{RAILS_ROOT}/vendor/gem_home/gems"
  end
  
  def vendor_plugins
    [
      :a_plugin_with_dependencies,
      :first_plugin,
      :plugin_with_exception,
      :second_plugin,
      :third_plugin
    ].collect {|name| plugin_path(name)}
  end
  
  def plugin_path(name)
    "#{plugins_path}/#{name}"
  end
  
  def gem_path(name)
    "#{gems_path}/#{name}"
  end
end