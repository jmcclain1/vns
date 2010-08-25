require File.dirname(__FILE__) + '/../../spec_helper'
require 'rexml/document'

include REXML

describe "/prospects/index.rxml" do

  it "returns the correct vehicle information in xml" do
    view.stub!(:logged_in_user).and_return(users(:charlie))
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    assigns[:prospects] = [prospect]
    render "/prospects/index.rxml"
    doc = Hpricot::XML(response.body)
    doc.at("//tr[1]/td[1]/span[1]").inner_html.should == prospect.listing.vehicle.year.to_s
    doc.at("//tr[1]/td[1]/div[@class='source']/span").inner_html.should == prospect.source
    doc.at("//div[@class='thumb']/a/img").should_not be(nil)
    doc.at("//tr[1]/td[2]/a[1]").inner_html.should == "#{prospect.listing.vehicle.make_name} #{prospect.listing.vehicle.model_name}"
    _, vin = extract_vin(doc)
    vin.should == prospect.listing.vehicle.vin
    doc.at("//tr[1]/td[2]/div/span[1]").inner_html.should == prospect.listing.vehicle.exterior_color.name
    # interior color, dealership location (city, state), exterior color
    # mileage
    # distance, zip
    # price
    # status, my offer, high offer, message count

#    doc = REXML::Document.new(response.body)
#    XPath.first(doc,"//td[1]/div").text.strip.should == vehicle.year.to_s
#    XPath.first(doc,"//td[2]/div/p[1]/a").attributes["href"].should == vehicle_path(vehicle)
#    XPath.first(doc,"//td[2]/div/p[1]/a/b").text.should == "#{vehicle.make_name} #{vehicle.model_name}"
#    XPath.first(doc,"//td[2]/div/p[1]/a").text.strip.should == "Certified" if vehicle.certified
#    miles, color = XPath.first(doc,"//td[2]/div/p[2]").text.split(",").map {|s| s.strip }
#    miles.should == "#{vehicle.odometer} Miles"
#    color.should == "#{vehicle.exterior_color.name}/#{vehicle.interior_color.name}"
#    _, vin, stock_no = extract_vin_and_stock_number(doc)
#    vin.should == vehicle.vin
#    stock_no.should == vehicle.stock_number
#    XPath.first(doc,"//td[3]/div").text.strip.should == "#{vehicle.days_in_inventory} days in inventory"
#    XPath.first(doc,"//td[4]/div/p[1]").text.should == "Listed by #{vehicle.listing.lister.full_name}"
#    XPath.first(doc,"//td[4]/div/p[2]/a").attributes["href"].should == listing_path(vehicle.listing)
#    XPath.first(doc,"//td[4]/div/p[2]/a").text.should == "View Listing"
  end

  private
  def extract_vin(doc)
    /VIN: (\w+)/.match(doc.at("//tr[1]/td[2]").inner_html).to_a
  end
end