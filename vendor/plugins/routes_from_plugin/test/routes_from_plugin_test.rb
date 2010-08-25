dir = File.dirname(__FILE__)
require "#{dir}/test_helper"

class RoutesFromPluginTest < Pivotal::FrameworkPluginTestCase
  include PluginUtils
  include FlexMock::TestCase

  def test_routes_from_plugin
    map = ActionController::Routing::RouteSet::Mapper.new(nil)
    flexstub(map).should_receive(:named_route).once
    map.routes_from_plugin(:routes_from_plugin)
  end
end
