require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class LayoutTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_app_controller_and_plugin_layout
    @controller = AppWithPluginLayoutController.new
    expected = "ViewSkeleton Layout-ViewSkeleton Index"
    
    assert_equal expected, get(:index).body
  end
  
  def test_plugin_controller_and_app_layout
    @controller = PluginWithAppLayoutController.new
    expected = "App Layout-App Index"
    assert_equal expected, get(:index).body
  end
  
  def test_app_controller_and_app_layout
    @controller = AppWithAppLayoutController.new
    expected = "App Layout-App Index"
    assert_equal expected, get(:index).body
  end
  
  # View is located in a different plugin than the layout
  def test_plugin_with_plugin_layout
    @controller = PluginWithPluginLayoutController.new
    expected = "ControllerSkeleton Layout-ViewSkeleton Index"
    assert_equal expected, get(:index).body
  end
  
  def test_plugin_controller_and_different_plugin_layout
    @controller = PluginWithOtherPluginLayoutController.new
    expected = "ViewSkeleton Layout-ViewSkeleton Index"
    assert_equal expected, get(:index).body
  end
end