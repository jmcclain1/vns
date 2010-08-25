dir = File.dirname(__FILE__)
require dir + "/selenium_helper"

class VnsSeleniumTestCase < Pivotal::SeleniumTestCase

  fixtures *self.all_fixture_symbols
  self.use_instantiated_fixtures = false

  def login(user)
    open "/"
    assert_text_present("Log in", nil, {:timeout=>120.seconds})
    
    type "id=user_email_address", user.unique_name
    type "id=user_password", "password"
    click_and_wait_for_page_to_load "id=login_button"
  end
end
