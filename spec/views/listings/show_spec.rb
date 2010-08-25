require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

module ListingScreenHelpers

  describe "SetUpListingScreen", :shared => true do
    before :each do
      log_in(users(:bob))
      @listing = users(:bob).dealership.listings[0]
      assigns[:listing] = @listing
      @vehicle = @listing.vehicle
      assigns[:vehicle] = @vehicle
      assigns[:logged_in_user] = users(:bob)
      
      session[:location] = {}
      session[:location][:controller] = "listings"

      setup_doc
    end

    def setup_doc
      render "/listings/show.mab"
      @doc = Hpricot(response.body)
    end

    def details_and_messages
      @doc.at("//div[@id='details_and_messages']")
    end

    def details_content
      return details_and_messages.at("/div[@id='listing_details_content']")
    end

    def messages_content
      @doc.at("//div[@id='details_and_messages']/div[@id='messages_and_offers_content']")
    end
  end
end

include ListingScreenHelpers

describe "/listings/show" do
  it_should_behave_like "SetUpListingScreen"

  it "should display basic information on the vehicle" do
    @doc.at("//h1").inner_html.should == @listing.vehicle_name

    @doc.at("//div[@id='basic_information']").inner_html.should include(@vehicle.odometer.to_s)
    @doc.at("//div[@id='basic_information']").inner_html.should include(@vehicle.transmission_name)
    @doc.at("//div[@id='basic_information']").inner_html.should include("#{@vehicle.doors} Doors")

    @doc.at("//div[@id='listing_box']").inner_html.should include(@listing.asking_price.to_currency)
  end

  it "should initially display the Listing Details subtab" do
    details_content[:style].should == 'display: block;'
    messages_content[:style].should == 'display: none;'
  end
  
  it "should have a Cancel Listing button if the vehicle is not canceled" do
    @doc.at("//div[@id='details_tabs']").inner_html.should include("Cancel Listing")
  end
end

describe "Listing Details subtab" do
  it_should_behave_like "SetUpListingScreen"

  before :each do
    details_content[:style] = nil
    messages_content[:style] = 'display:none'
  end

  it "should show the vehicle details" do
    details = details_content.at("//div[@id=details]")
    details.should_not be_nil

    title = details.at("/div/h2")
    title.should_not be_nil
    title.inner_html.should == "Vehicle Details"
  end

  it "should show the listing details"

end

describe "Messages and Offers subtab" do
  it_should_behave_like "SetUpListingScreen"

  before :each do
    details_content[:style] = 'display:none'
    messages_content[:style] = nil
  end

  it "should display all messages"

  it "should select the first message by default"
end
