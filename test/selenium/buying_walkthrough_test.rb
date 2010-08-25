require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class BuyingWalkthroughTest < VnsSeleniumTestCase
  def setup
    super
    login users(:bob)

    open '/prospects'
    assert_in_prospect_inbox

    @malibu = listings(:pivotal_listing_3)
    @malibu_name = "#{@malibu.vehicle.make_name} #{@malibu.vehicle.model_name}"
  end

  def teardown
    super
    click_and_wait "id=log_out"
  end

  def test_walkthrough
    go_to_find_vehicles_tab
    add_first_listing_to_inbox
    go_to_prospect_inbox

    assert_text_present @malibu_name
    remove_first_prospect_from_inbox
    assert_text_not_present @malibu_name
  end

  def go_to_find_vehicles_tab
    click_and_wait 'find_vehicle_tab'
    
  end

  def add_first_listing_to_inbox
    assert_element_present "add_to_inbox_#{@malibu.id}"
    click_and_wait "add_to_inbox_#{@malibu.id}"
  end

  def go_to_prospect_inbox
    assert_element_present 'prospect_inbox'
    click_and_wait 'prospect_inbox'
    assert_in_prospect_inbox
  end

  def remove_first_prospect_from_inbox
    assert_element_present "remove_from_inbox_#{@malibu.id}"
    click_and_wait "remove_from_inbox_#{@malibu.id}"
  end

  def assert_in_prospect_inbox
    assert_text_present 'All Opportunities'
  end

end
