require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module ActionMailer
  class Base
    public :template_path
  end
end

class ActionMailerTest < Test::Unit::TestCase
  def test_template_path
    # Need to use allocate since initialize won't give us the instance
    mailer = UserNotifications.allocate
    
    # The name of the mailer won't be appended to the template path since we're
    # using allocate and the defaults aren't instantiated yet
    expected = [
      "#{app_root}/views/",
      "#{plugin_root}/view_skeleton/app/views/",
      "#{plugin_root}/very_high_priority_view_skeleton/app/views/",
      "#{plugin_root}/plugin_routing/app/views/",
      "#{plugin_root}/mailer_skeleton/app/views/",
      "#{plugin_root}/high_priority_view_skeleton/app/views/",
      "#{plugin_root}/controller_skeleton/app/views/"
    ]
    
    assert_equal "{#{expected * ','}}", mailer.template_path
  end
end