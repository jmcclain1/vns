require File.dirname(__FILE__) + '/../../spec_helper'
require 'rexml/document'

include REXML

describe "/vehicles/index.rxml" do
  fixtures :vehicles

  it "returns the correct vehicle information in xml" do
    vehicle = vehicles(:jetta_vehicle_1)
    assigns[:vehicles] = [vehicle]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[1]/span").text.strip.should == vehicle.year.to_s
    XPath.first(doc,"//td[2]/a").attributes["href"].should == vehicle_path(vehicle)
    XPath.first(doc,"//td[2]/a").text.should == "#{vehicle.make_name} #{vehicle.model_name}"
    XPath.first(doc,"//td[2]/span").text.strip.should == "Certified" if vehicle.certified
    XPath.first(doc,"//td[2]/span[2]") == "#{vehicle.odometer} Miles"
    XPath.first(doc,"//td[2]/span[3]") == "#{vehicle.exterior_color.name}/#{vehicle.interior_color.name}"
    XPath.first(doc,"//td[2]//div[@class='number_details']/span[1]") == vehicle.vin
    XPath.first(doc,"//td[2]//div[@class='number_details']/span[1]") == vehicle.stock_number
    XPath.first(doc,"//td[3]/span").text.strip.should == "#{vehicle.days_in_inventory}"
    XPath.first(doc,"//td[4]/span[1]").text.should == "#{vehicle.listing.lister.full_name}"
    XPath.first(doc,"//td[4]/p[1]/a").attributes["href"].should == listing_path(vehicle.listing)
    XPath.first(doc,"//td[4]/p[1]/a").text.should == "View Listing"
  end

  it "displays 'Unlisted' if the vehicle is not listed" do
    not_listed_vehicle = vehicles(:jetta_vehicle_2)
    assigns[:vehicles] = [not_listed_vehicle]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/span/em").text.should == 'Unlisted'
  end

  it "displays appropriate message, and no 'create listing' button, if the vehicle has no title" do
    not_listed_vehicle = vehicles(:jetta_vehicle_2)
    assigns[:vehicles] = [not_listed_vehicle]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/p[1]").text.should == 'No Title'
    XPath.first(doc,"//td[4]/p[1]").attributes["style"].should == "color:red"
    XPath.first(doc,"//td[4]/p[2]").text.should == 'Title required to list vehicle'
    XPath.first(doc,"//td[4]/form/input[@id='create_listing_btn']").should be_nil    
  end

  it "returns 'Unlisted' if the vehicle's listing is in draft state" do
    vehicle = vehicles(:jetta_vehicle_1)
    Listing.delete_all
    listing = Listing.new(:vehicle => vehicle, :dealership => dealerships(:valid_dealership_1))
    listing.save(false)
    assigns[:vehicles] = [vehicle]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/span/em").text.should == 'Unlisted'
    XPath.first(doc,"//td[4]/p[1]").text.should == 'Listing has been started'
    XPath.first(doc,"//td[4]/form/a[@id='create_listing_btn_#{vehicle.to_param}']/span").text.should == "Continue Listing"
  end

  it "shows a button to create a listing if it is unlisted and it is listable" do
    not_listed_vehicle_with_title = vehicles(:jetta_vehicle_4)
    assigns[:vehicles] = [not_listed_vehicle_with_title]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/span/em").text.should == 'Unlisted'
    XPath.first(doc,"//td[4]/form").should_not == nil
    XPath.first(doc,"//td[4]/form/a[@id='create_listing_btn_#{not_listed_vehicle_with_title.to_param}']/span").text.should == "Create Listing"
  end

  it "shows 'Title required' text if it is unlisted and we do not have a title" do
    not_listed_vehicle_without_title = vehicles(:jetta_vehicle_2)
    assigns[:vehicles] = [not_listed_vehicle_without_title]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/span/em").text.should == 'Unlisted'
    XPath.first(doc,"//td[4]/p[1]").text.should == 'No Title'
    XPath.first(doc,"//td[4]/p[1]").attributes["style"].should == "color:red"
    XPath.first(doc,"//td[4]/p[2]").text.should == 'Title required to list vehicle'
  end

  it "returns 'No Title' if we do not have the title for the vehicle" do
    vehicle_where_we_dont_have_title = vehicles(:jetta_vehicle_2)
    assigns[:vehicles] = [vehicle_where_we_dont_have_title]
    render "/vehicles/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//td[4]/span/em").text.should == 'Unlisted'
    XPath.first(doc,"//td[4]/p[1]").text.should == 'No Title'
    XPath.first(doc,"//td[4]/p[1]").attributes["style"].should == "color:red"
    XPath.first(doc,"//td[4]/p[2]").text.should == 'Title required to list vehicle'
  end

  private
  def extract_vin_and_stock_number(doc)
    /Vin# (\w+) Stock# (\w+)/.match(XPath.first(doc,"//td[2]/div/p[3]").text).to_a
  end
end