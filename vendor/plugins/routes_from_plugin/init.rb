require_plugin 'plugin_utils'
require 'routes_from_plugin'

class ActionController::Routing::RouteSet::Mapper
  include RoutesFromPlugin::MapperExtension
end