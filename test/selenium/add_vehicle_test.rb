require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class AddVehicleTest < VnsSeleniumTestCase

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
    click_and_wait("link=Add Vehicle To Inventory")

    @vehicle = Vehicle.find(:all).last

    unknown_vin
    known_vin
    edit_vehicle_details
    listing
  end

  def invalid_vin
    type "id=vehicle_vin", "xyz"
    click_and_wait "id=proceed_button"
    assert_text_present "Vin is the wrong length"
  end

  def unknown_vin
    type "id=vehicle_vin", "12345678901234567"
    click_and_wait "id=proceed_button"
    assert_text_not_present "Please enter a valid VIN."
    assert_text_present "We could not locate that VIN in our database."
  end

  def known_vin
    # step 1
    assert_step "Enter VIN"
    type "id=vehicle_vin", "1FDNW21508E123456"
    click_and_wait "id=proceed_button"

    # step 2
    assert_step "Select Vehicle"
    assert_text_present "2008 Ford F-250 XL"
    click "xpath=//li[2]//input[@name='vehicle[trim_id]']"
    click_and_wait "id=proceed_button"

    # step 3 (with errors)
    assert_step "Complete Vehicle Details"
    click_and_wait "id=proceed_button"

    assert_step "Complete Vehicle Details"
    assert_text_present "Odometer is not a number"
    assert_text_present "Stock number can't be blank"

    # step 3 (without errors)
    click "id=vehicle_title_true"
    type "id=vehicle_title_state", "CA"
    type "id=vehicle_odometer", "123.4"
    type "id=vehicle_stock_number", "xyz"
    type "id=vehicle_cost", "1.00"
    type "id=vehicle_actual_cash_value", "2.00"
    click "id=vehicle_certified_true"
    click_and_wait "id=proceed_button"

    # step 4
    assert_step "Add Photos"
    click_and_wait "id=proceed_button"

    # step 5
    assert_step "Summary"
    assert_text_present "123.4"
    assert_text_present "xyz"

    # Vehicle photos should not be editable
    assert_element_not_present "id=upload_photo"
    assert_element_not_present "id=make_photo_primary"
    assert_element_not_present "id=delete_photo"

    click_and_wait "id=proceed_button"

    # Details page
    assert_text_present "Vehicle Details"
  end

  def listing
    click_and_wait "link=Create Listing"
    assert_text_present "Complete Vehicle Information"
  end

  def edit_vehicle_details
    assert_text "//h2/span", 'Certified'

    click "edit_vehicle_details_popup_toggle_button"
    assert_visible "id=edit_vehicle_details_popup"

    type "id=vehicle_odometer", 'dfg'
    click "edit_vehicle_details_popup_button_submit"
    assert_text_present 'not a number'

    type "id=vehicle_odometer", '12'
    type "id=vehicle_location", 'ABCD12341'
    click "vehicle_certified_false"
    click_and_wait "edit_vehicle_details_popup_button_submit"

    assert_text_not_present 'not a number'
    assert_text_present 'ABCD12341'
    assert_text "//h2/span", ''
    assert_not_visible "id=edit_vehicle_details_popup"
  end

  private
  def assert_step(expected)
    assert_text "xpath=//li[@class='active']//span[@class='text']", expected
  end
end
