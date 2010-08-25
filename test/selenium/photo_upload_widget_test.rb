require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class PhotoUploadWidgetTest < VnsSeleniumTestCase

  def setup
    super
    login users(:bob)
  end

  def teardown
    super
    teardown_photo_widget

    click_and_wait "id=log_out"
  end

  def test_widget
    @vehicle = vehicles(:jetta_vehicle_1)
    setup_photo_widget
    open "/vehicles/#{@vehicle.id}"
    assert_photo_widget
  end

  private

  def setup_photo_widget
    @vehicle.add_photo(fixture_file_upload("uploaded/vehicle_1.jpg", "image/jpg"))
    @vehicle.add_photo(fixture_file_upload("uploaded/vehicle_2.jpg", "image/jpg"))
    @photo_ids = @vehicle.photos.map(&:id)
  end

  def teardown_photo_widget
    @vehicle.photos.each do |photo|
      photo.destroy
    end
  end

  def assert_photo_widget
    within_frame(0) do
      # initial state... vehicle_1 is primary and selected
      assert_preview_present('vehicle_1.jpg')
      assert_thumbnail_present(0, 'vehicle_1.jpg')
      assert_thumbnail_present(1, 'vehicle_2.jpg')

      # select vehicle_2 (vehicle_1 is still primary)
      click_thumbnail(1)
      assert_preview_present('vehicle_2.jpg')
      assert_thumbnail_present(0, 'vehicle_1.jpg')
      assert_thumbnail_present(1, 'vehicle_2.jpg')

      # make vehicle_2 primary (reloads, swaps thumbnail order, and adds 'primary_thumbnail' class to primary)
      submit_form_in_frame('make_photo_primary')
      assert_preview_present('vehicle_2.jpg')
      assert_thumbnail_present(0, 'vehicle_2.jpg')
      assert_thumbnail_present(1, 'vehicle_1.jpg')

      # select vehicle_1 and delete
      click_thumbnail(1)
      assert_preview_present('vehicle_1.jpg')
      submit_form_in_frame('delete_photo')
      assert_preview_present('vehicle_2.jpg')
      assert_thumbnail_present(0, 'vehicle_2.jpg')
    end
  end
end