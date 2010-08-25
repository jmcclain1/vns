require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class SignupSigninTest < VnsSeleniumTestCase

  def setup
    super
    open "/"
  end

  def test_login
    login(users(:bob))

    assert_text_present "Welcome, Bob Valid"
    click "id=log_out"
    assert_text_not_present "Welcome, Bob Valid"
  end

#  def test_signup_and_signin_flow
#    login(users(:bob))
#    click_and_wait "id=signup"
#
#    click_and_wait "id=signup_button"
#    assert_text_present "Please confirm your password"
#    assert_text_present "Unique name can't be blank"
#    assert_text_present "Unique name must be composed of letters, digits, underscores, or hyphens"
#    assert_text_present "Password is too short (minimum is 3 characters)"
#    assert_text_present "Please enter your password"
#    assert_text_present "The email address you provided is not valid"
#
#    type "id=user_unique_name", "crazyeddie"
#    type "id=user_email_address", "crazyeddie@example.com"
#    type "id=user_password", "insane"
#    type "id=user_password_confirmation", "insane"
#    click_and_wait "id=signup_button"
#
#    assert_text_present "We've sent you an email to confirm your registration."
#    wait_for { email_was_delivered? }
#    email = ActionMailer::Base.deliveries.first
#
#    uris = URI.extract(email.body).select {|uri| !uri.ends_with?(":")}
#    link = uris.first
#    open link
#    wait_for_page_to_load
#  end
#
#  def email_was_delivered?
#    not ActionMailer::Base.deliveries.empty?
#  end

end
