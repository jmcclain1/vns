# Load the environment
ENV['RAILS_ENV'] ||= 'test'
require File.dirname(__FILE__) + '/rails_root/config/environment.rb'

# Load the testing framework
require 'test_help'

class Test::Unit::TestCase
  def app_root
    "#{RAILS_ROOT}/app"
  end
  
  def plugin_root
    "#{RAILS_ROOT}/vendor/plugins"
  end
end