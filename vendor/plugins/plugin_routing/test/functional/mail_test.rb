require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class MailTest < Test::Unit::TestCase
  def test_notification_in_plugin
    mail = UserNotifications.create_password_reminder
    assert_equal 'MailerSkeleton PasswordReminder', mail.body
  end
  
  def test_notification_in_app
    mail = UserNotifications.create_signup_notification
    assert_equal 'App SignupNotification', mail.body
  end
end