module ::PluginAWeek
  module PluginDependencies
    mattr_accessor :plugin_exception_thrown
  end
end

require 'first_plugin'
require_plugin 'second_plugin'
plugin 'third_plugin'

begin
  require 'plugin_with_exception'
rescue Exception => ex
  PluginAWeek::PluginDependencies.plugin_exception_thrown = ex
end