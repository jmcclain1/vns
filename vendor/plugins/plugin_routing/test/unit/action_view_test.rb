require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module ActionView
  class Base
    public :full_template_path
  end
end

class ActionViewTest < Test::Unit::TestCase
  def setup
    @action_view = ActionView::Base.new(ActionController::Base.template_root)
  end
  
  def test_path_only_in_app
    assert_equal "#{app_root}/views/site/terms_of_service.rhtml", @action_view.full_template_path('site/terms_of_service', 'rhtml')
  end
  
  def test_path_in_app_and_plugin
    assert_equal "#{app_root}/views/site/contact.rhtml", @action_view.full_template_path('site/contact', 'rhtml')
  end
  
  def test_path_only_in_plugin
    assert_equal "#{plugin_root}/very_high_priority_view_skeleton/app/views/site/about.rhtml", @action_view.full_template_path('site/about', 'rhtml')
  end
  
  def test_path_in_multiple_plugins
    assert_equal "#{plugin_root}/very_high_priority_view_skeleton/app/views/site/search.rhtml", @action_view.full_template_path('site/search', 'rhtml')
  end
  
  def test_path_not_in_app_or_plugins
    assert_equal "#{app_root}/views/site/privacy_policy.rhtml", @action_view.full_template_path('site/privacy_policy', 'rhtml')
  end
end