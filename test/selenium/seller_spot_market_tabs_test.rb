require File.dirname(__FILE__) + "/selenium_helper"

class SellerSpotMarketTabsTest < VnsSeleniumTestCase

  def setup
    super
    login users(:bob)
  end

  def teardown
    super
    click_and_wait "id=log_out"
  end

  def test_walkthrough
    @vin     = "123456701234567A9"
    @vehicle = Vehicle.find_by_vin(@vin)

    open "/listings"

    @listing = Listing.find(:all).first

    click_on_show_listing_link
    assert_listing_details_subtab_is_active

    click_on_messages_and_offers_subtab
    assert_messages_and_offers_subtab_is_active

    click_on_listing_details_subtab
    assert_listing_details_subtab_is_active
  end

  def click_on_show_listing_link
    listing_details_link = "xpath=id('listings_grid_1_1')/a"
    assert_element_present listing_details_link, :timeout => 20
    click_and_wait listing_details_link
  end

  def assert_listing_details_subtab_is_active
    assert_visible "id=listing_details_content"
    assert_not_visible "id=messages_and_offers_content"
  end

  def assert_messages_and_offers_subtab_is_active
    assert_not_visible "id=listing_details_content"
    assert_visible "id=messages_and_offers_content"
  end

  def click_on_messages_and_offers_subtab
    click("//div[@id='messages_and_offers_content_tab']/a")
  end

  def click_on_listing_details_subtab
    click("//div[@id='listing_details_content_tab']/a")
  end
end