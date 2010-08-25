# RAILS_GEM_VERSION = '1.2.0' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

$:.unshift("#{RAILS_ROOT}/../../../plugin_dependencies/lib")
$:.unshift("#{RAILS_ROOT}/../../../loaded_plugins/lib")

require 'plugin_dependencies'

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.breakpoint_server = true
  config.load_paths.concat([
    "#{RAILS_ROOT}/app/models/fake_namespace",
    "#{RAILS_ROOT}/app/mailers",
    "#{RAILS_ROOT}/../../lib"
  ])
end

Dependencies.log_activity = true