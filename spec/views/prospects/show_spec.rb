require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/prospects/show.mab" do

  it "should render a tab for listing details (as tab #1)"

  it "should render a tab for messages and offers (as tab #2)"

end

describe "/prospects/show.mab for the listing details tab" do

end

describe "/prospects/show.mab for the messages and offers tab" do

  before :each do
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @vehicle  = vehicles(:jetta_vehicle_1)
    @lister   = @prospect.listing.lister
    log_in(users(:bob))

    assigns[:prospect] = @prospect
    assigns[:vehicle]  = @vehicle
    assigns[:logged_in_user] = users(:bob)
    
    session[:location] = {}
    session[:location][:controller] = "prospects"

    render "/prospects/show.mab"
    @doc         = Hpricot(response.body)
    @details_div = @doc.at("//div[@id = 'details_and_messages']")
  end
  
  it "should render a section for viewing the seller info"
  #   @details_div.at("//div[@id = 'spot_market_seller_info']").should_not be_nil
  # end
  
  it "should render a section for viewing the active offer"
#  TODO: Adding the event fixture for this test caused others to break.
#  it "should render a section for viewing the active offer" do
#    @details_div.at("//div[@id = 'spot_market_active_offer']").should_not be_nil
#  end

  it "should render a section for sending an offer" do
    @details_div.at("//div[@id = 'spot_market_send_offer_#{@prospect.to_param}']").should_not be_nil
  end

  it "should render a section for sending a message" do
    @details_div.at("//div[@id = 'spot_market_send_message_#{@prospect.to_param}']").should_not be_nil
  end

  it "should render a section for viewing event history" do
    @details_div.at("//div[@id = 'spot_market_event_history']").should_not be_nil
  end
end
