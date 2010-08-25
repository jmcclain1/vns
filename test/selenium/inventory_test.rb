require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class InventoryTest < VnsSeleniumTestCase

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
    open_and_close_vehicle_detail_tabs
    open_vehicle_details_and_delete_vehicle
  end

  def open_and_close_vehicle_detail_tabs
    mini_tab_to_inventory_list = "xpath=id('navigation')/div[2]/div/div[1]/a"
    hhr_2008_details_link = "xpath=id('vehicles_grid_0_1')/a"
    impala_2008_details_link = "xpath=id('vehicles_grid_1_1')/a"

    assert_element_present hhr_2008_details_link, :timeout => 20
    click_and_wait hhr_2008_details_link
    assert_text_present "Vehicle Details"
    click_and_wait mini_tab_to_inventory_list

    assert_on_inventory_list_page
    assert_text_present "2008 Chevrolet HHR LS, 1234", "Minitab for 2008 Chevrolet HHR LS, 1234 should persist", :timeout => 20

    assert_element_present impala_2008_details_link, :timeout => 20
    click_and_wait impala_2008_details_link
    assert_text_present "Vehicle Details"

    click_and_wait mini_tab_to_inventory_list
    assert_on_inventory_list_page
    assert_text_present "2008 Chevrolet Impala LT w/3.5L, 1234",
                        "Minitab for 2008 Chevrolet Impala LT w/3.5L, 1234 should persist", :timeout => 20
    assert_text_not_present "2008 Chevrolet HHR LS, 1234", "Minitab for 2008 Chevrolet HHR LS, 1234 should have been closed since only one tab can be open at a time", :timeout => 20
  end

  def open_vehicle_details_and_delete_vehicle
    jetta_2005_details_link = "xpath=id('vehicles_grid_0_1')/a"
    jetta_vehicle = vehicles(:jetta_vehicle_from_2000)

    assert_not_nil jetta_vehicle.dealership
    assert_element_present jetta_2005_details_link
    click_and_wait jetta_2005_details_link
    assert_text_present "Vehicle Details"
    click_and_wait 'remove_from_inventory_button'

    assert_on_inventory_list_page
    jetta_vehicle.reload
    assert_nil jetta_vehicle.dealership
  end

  private
  def assert_on_inventory_list_page
    assert_text_present "Listing vehicles", :timeout => 20
  end
end
