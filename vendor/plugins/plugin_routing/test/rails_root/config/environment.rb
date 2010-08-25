# RAILS_GEM_VERSION = '1.2.0' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

$:.unshift("#{RAILS_ROOT}/../../../../rails/appable_plugins/lib")
$:.unshift("#{RAILS_ROOT}/../../../../rails/loaded_plugins/lib")

require 'appable_plugins'
require 'loaded_plugins'

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.breakpoint_server = true
  config.load_paths << "#{RAILS_ROOT}/../../lib"
end