require File.dirname(__FILE__) + '/../../spec_helper'
require 'rexml/document'

include REXML

describe "/listings/index.rxml" do

  it "returns the correct vehicle information in xml" do
    view.stub!(:logged_in_user).and_return(users(:bob))
    listing = listings(:alices_listing_1)
    assigns[:listings] = [listing]
    render "/listings/index.rxml"


    doc = Hpricot::XML(response.body)
    doc.at("//tr[1]/td[1]/span[1]").inner_html.should == listing.vehicle.year.to_s
    doc.at("//div[@class='thumb']/a/img").should_not be(nil)
    doc.at("//tr[1]/td[2]/a[1]").inner_html.should == "#{listing.vehicle.make_name} #{listing.vehicle.model_name}"
    _, vin = extract_vin(doc)
    vin.should == listing.vehicle.vin
    doc.at("//tr[1]/td[2]/div/span[1]").inner_html.should == listing.vehicle.exterior_color.name
    # interior color, dealership location (city, state), exterior color
    # mileage
    # distance, zip
    # price
    # status, my offer, high offer, message count
  end

  private
  def extract_vin(doc)
    /VIN: (\w+)/.match(doc.at("//tr[1]/td[2]").inner_html).to_a
  end
end