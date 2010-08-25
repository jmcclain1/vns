require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/vehicles/show" do
  include VehiclesHelper
  
  before do
    red = mock("Red")
    red.stub!(:id).and_return(1001)
    red.stub!(:name).and_return("red")
    blue = mock("Blue")
    blue.stub!(:id).and_return(10012)
    blue.stub!(:name).and_return("blue")
    log_in(users(:bob))
    assigns[:logged_in_user] = users(:bob)

    session[:location] = {}
    session[:location][:controller] = "vehicles"
    
    @vehicle = vehicles(:jetta_vehicle_1)
    assigns[:vehicle] = @vehicle
  end

  def render_view
    render "/vehicles/show.mab"
    Hpricot(response.body)
  end

  it "displays 'Certified' if the vehicle is certified" do
    doc = render_view
    doc.at("//h2[@id='display_name']").inner_html.should include("<span class=\"certified\">Certified</span>")
  end

  it "does not display 'Certified' if the vehicle is not certified" do
    @vehicle.stub!(:certified).and_return(false)
    doc = render_view
    doc.at("//h2[@id='display_name']").inner_html.should include("<span class=\"certified\"></span>")
  end

  it "displays 'No Title' under the page header if the vehicle has no title" do
    @vehicle.stub!(:title).and_return(false)
    @vehicle.stub!(:listable?).and_return(false)
    @vehicle.stub!(:listed?).and_return(false)
    @vehicle.stub!(:listing).and_return(nil)
    doc = render_view
    doc.at("//div[@id='unlisted_box']/div/span[3]").inner_html.should == '(Vehicles with <span class="no_title">No Title</span> can not be listed)'
  end

  it "does not display 'No Title' under the page header if the vehicle has a title" do
    @vehicle.stub!(:title).and_return(true)
    doc = render_view
    doc.at("//div[@id='top_title_status']").should == nil
  end

  it "does not display 'Unlisted' if vehicle has a listing" do
    doc = render_view
#    TODO: How do you check "unlisted" *doesn't* occur on the page?
  end

  it "enables 'Create Listing' button if the vehicle is listable" do
    @vehicle.stub!(:listing).and_return(nil)
    @vehicle.stub!(:listable?).and_return(true)
    @vehicle.stub!(:listed?).and_return(false)
    doc = render_view
    doc.at("//a[@id='create_listing_btn_#{@vehicle.to_param}']")[:class].should == 'button'
    doc.at("//div[@id='listing_band']/span").should == nil
  end
  
  it "disables 'Create Listing' button if the vehicle is not listable" do
    @vehicle.stub!(:listable?).and_return(false)
    @vehicle.stub!(:listing).and_return(nil)
    @vehicle.stub!(:listed?).and_return(false)
    doc = render_view
    doc.at("//a[@id='create_listing_btn_#{@vehicle.to_param}']")[:class].should == 'button button_disabled'
    doc.at("//div[@id='unlisted_box']/div/span[2]").inner_html.should == '<span class="no_title">No Title</span>'
  end

  it "replaces the 'Create Listing' button with the 'View Listing' button if the vehicle already has a listing" do
    lister = mock_model(User, {:id => 107, :full_name => "Mr. Clean"})
    listing = mock_model(Listing, {:id => 99, :auction_end => Time.now, :active_offers => 2, :lister => lister})
    @vehicle.stub!(:listing).and_return(listing)
    @vehicle.stub!(:listed?).and_return(true)
    doc = render_view
    doc.at("//a[@id='view_listing_btn']").inner_html.should == 'View Listing'
  end

  it "shows a 'Remove from inventory' button if the vehicle has not been listed" do
    @vehicle.stub!(:listing).and_return(nil)
    @vehicle.stub!(:listed?).and_return(false)
    doc = render_view
    doc.at("//form//a[text()='Remove from inventory']").should_not be(nil)
  end

  it "shows something other than the 'Remove from inventory' button if the vehicle has been listed" do
    doc = render_view
    doc.at("//form//input[@value='Remove from inventory']").should be(nil)
  end

  it "displays the vehicle photo widget" do
    doc = render_view
    doc.at("//iframe[@id = 'vehicle_photos_container']").should_not be(nil)
  end

  def create_vehicle_photo(id, small_url, large_url)
    vehicle_photo = mock('VehiclePhoto')
    vehicle_photo_small = mock('VehiclePhotoVersion')
    vehicle_photo_small.stub!(:url).and_return(small_url)
    vehicle_photo_large = mock('VehiclePhotoVersion')
    vehicle_photo_large.stub!(:url).and_return(large_url)
    vehicle_photo.stub!(:versions).and_return(:small => vehicle_photo_small, :large => vehicle_photo_large)
    vehicle_photo.stub!(:id).and_return(id)
    return vehicle_photo
  end

end

