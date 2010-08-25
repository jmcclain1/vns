require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class AddListingTest < VnsSeleniumTestCase

  def setup
    super
    login users(:bob)
  end

  def teardown
    super
    click_and_wait "id=log_out"
  end

  def test_walkthrough
    @vin     = "1FDNW21508E123456"
    @vehicle = Vehicle.find_by_vin(@vin)

    open "/listings"
    click_and_wait("link=Create New Listing")

    @listing = Listing.find(:all).last
    @listing.auction_start = Time.parse("Aug 31 2007")
    @listing.save(false)
    walkthrough_page1
    walkthrough_page2
    walkthrough_page3
    walkthrough_page4
    walkthrough_page5
  end

  def walkthrough_page1
    assert_text_present "Enter Inventory Stock # or VIN #"
    # should validate fields
    click_and_wait("//a[@id='proceed_button']")
    assert_text_present "Please enter either a VIN or a stock number"
    # should proceed to next page
    type "vin", @vin
    click_and_wait("proceed_button")
  end

  def walkthrough_page2
    assert_text_present "Review Vehicle Details and Features"
    assert_text "id=vin", @vin
    # should proceed to next page
    click_and_wait("proceed_button")
  end

  def walkthrough_page3
    assert_text_present "Specify Terms"

    # should validate fields
    type "id=listing_asking_price", ""
    type "id=listing_accept_trade_rules", ""
    click_and_wait("proceed_button")
    assert_text_present "Asking price can't be blank"
    assert_text_present "Trade rules must be accepted"

    # should update time via ajax
    assert_text "id=auction_end", "Auction will end on 09/02/2007 @ 00:00"

    select "id=listing_auction_duration", "1 week"
    assert_text "id=auction_end", "Auction will end on 09/07/2007 @ 00:00"

    # should proceed to next page
    type "id=listing_asking_price", "100"
    click "id=listing_accept_trade_rules"

    click_and_wait("proceed_button")
  end

  def walkthrough_page4
    assert_text_present "Specify your partners"
    #todo not implemented yet
  end

  def walkthrough_page5
    #todo not implemented yet
  end


  # Assert and wait for locator element to have text equal to passed in text.
  def assert_text_matches(locator, regexp, options={})
    assert_element_present locator
    wait_for(options) do |context|
      actual = selenium.get_text(locator)
      context.message = "Expected /#{regexp}/ to match of #{locator} but was '#{actual}')"
      text == actual
    end
  end


end
