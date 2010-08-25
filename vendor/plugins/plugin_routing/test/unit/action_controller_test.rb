require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module ActionController
  module Layout
    module ClassMethods
      public :layout_list
    end
  end
end

class ActionControllerTest < Test::Unit::TestCase
  def test_layout_list
    expected = [
      "#{app_root}/views/layouts/app_with_app_layout.rhtml",
      "#{app_root}/views/layouts/plugin_with_app_layout.rhtml",
      "#{app_root}/views/layouts/site.rhtml",
      "#{plugin_root}/controller_skeleton/app/views/layouts/plugin_with_app_layout.rhtml",
      "#{plugin_root}/controller_skeleton/app/views/layouts/plugin_with_plugin_layout.rhtml",
      "#{plugin_root}/high_priority_view_skeleton/app/views/layouts/site.rhtml",
      "#{plugin_root}/very_high_priority_view_skeleton/app/views/layouts/site.rhtml",
      "#{plugin_root}/view_skeleton/app/views/layouts/app_with_plugin_layout.rhtml",
      "#{plugin_root}/view_skeleton/app/views/layouts/plugin_with_other_plugin_layout.rhtml"
    ]
    
    assert_equal expected, ActionController::Base.layout_list.sort
  end
end