require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/vehicles/wizard/photos" do
  include VehiclesHelper
  
  before do
    vehicle_photo_1 = create_vehicle_photo(1, 'vehicle_photo_1.png')
    vehicle_photo_2 = create_vehicle_photo(2, 'vehicle_photo_2.png')
    @photos = [vehicle_photo_1,vehicle_photo_2]
    @vehicle = mock('Vehicle')
    @vehicle.should_receive(:primary_photo).any_number_of_times.and_return(vehicle_photo_1)
    @vehicle.should_receive(:photos).any_number_of_times.and_return(@photos)
    @vehicle.should_receive(:to_param).any_number_of_times.and_return(GOOD_VEHICLE_ID.to_s)
    @vehicle.should_receive(:id).any_number_of_times.and_return(1)
    assigns[:vehicle] = @vehicle
  end

  def view_name
    "/vehicles/wizard/add_photos.mab"
  end

  def controller_name
    view_name
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end

  it "should use the 'current_step' style for the fourth element of the wizard bar" do
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[4]")[:class].should == 'active'
  end

  it "should display the vehicle photo widget" do
    doc = render_view
    doc.at("//iframe[@id = 'vehicle_photos_container']").should_not be(nil)
  end
end

def create_vehicle_photo(id, url)
  vehicle_photo = mock('VehiclePhoto')
  vehicle_photo_thumb_small = mock('VehiclePhotoVersion')
  vehicle_photo_thumb_large = mock('VehiclePhotoVersion')
  vehicle_photo_thumb_small.stub!(:url).and_return("s_" + url)
  vehicle_photo_thumb_large.stub!(:url).and_return("l_" + url)
  vehicle_photo.stub!(:versions).and_return(:small => vehicle_photo_thumb_small, :large => vehicle_photo_thumb_large)
  vehicle_photo.stub!(:id).and_return(id)
  return vehicle_photo
end