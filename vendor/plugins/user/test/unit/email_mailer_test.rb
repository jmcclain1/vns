require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock'

class EmailMailerTest < UserPluginTestCase

  def setup
    super
  end

  def test_password_reset_request__without_valid_password_reset_token
    user = users(:valid_user)
    assert_raises(RuntimeError) {
      EmailMailer.deliver_password_reset_request(user, nil)
    }
  end

  def test_password_reset_request__with_valid_password_reset_token
    user = users(:valid_user)
    token = Token.create(:user => user)
    EmailMailer.deliver_password_reset_request(user, token)
    delivery = EmailMailer.deliveries.last
    assert_equal [user.email_address], delivery.to
    assert_equal "Example: Reset Your Password", delivery.subject
    assert_equal ["noreply@example.com"], delivery.from
  end
  
  def test_password_reset_request__with_valid_password_reset_token_and_custom_email_options
    user = users(:valid_user)
    token = Token.create(:user => user)
    EmailMailer.deliver_password_reset_request(user, token, :from => "custom_from@test.com", :subject => "Custom Subject")
    delivery = EmailMailer.deliveries.last
    assert_equal [user.email_address], delivery.to
    assert_equal "Custom Subject", delivery.subject
    assert_equal ["custom_from@test.com"], delivery.from
  end

  def test_account_creation_notice__delivered
    user = users(:valid_user)
    token = Token.create(:user => user)
    EmailMailer.deliver_account_creation_notice(user, token)

    assert_email_sent(
      "noreply@example.com",
      user.email_address,
      "Please validate your account",
      "Thank you for signing up with us!")
    delivery = EmailMailer.deliveries.last

    assert_contains "User Name : #{user.unique_name}", delivery.body
    assert_contains "Email Address : #{user.email_address}", delivery.body
  end
  
  def test_account_creation_notice__delivered_with_custom_email_options
    user = users(:valid_user)
    token = Token.create(:user => user)
    EmailMailer.deliver_account_creation_notice(user, token, :from => "custom_from@test.com", :subject => "Custom Subject")
    delivery = EmailMailer.deliveries.last
    assert_equal "Custom Subject", delivery.subject
    assert_equal ["custom_from@test.com"], delivery.from
  end

end
