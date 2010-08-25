require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class PartnersTest < VnsSeleniumTestCase

  def setup
    super
    login users(:bob)
  end

  def teardown
    super
    click_and_wait "id=log_out"
  end

  def test_walkthrough
    open "/vehicles"
    click_and_wait 'manage_tab_link'
    click_and_wait 'partner_manager_tab_link'

    assert_text_present 'My Partners'
  end
end
