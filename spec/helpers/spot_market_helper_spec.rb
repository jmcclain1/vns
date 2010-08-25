require File.dirname(__FILE__) + '/../spec_helper'

describe "setup", :shared => true do
  include ApplicationHelper

  before :each do
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @listing = @prospect.listing
    @lister = @listing.lister
    @buyer = @prospect.prospector
  end
end

describe SpotMarketHelper, "#spot_market_seller_info" do
  it_should_behave_like "setup"

  before :each do
    @doc = Hpricot(spot_market_seller_info(@prospect))
  end

  it "should render general information about the seller" do
    @doc.at('div[@id = "spot_market_seller_info"]').should_not be_nil
    @doc.at('div[@id = "spot_market_seller_info"]').inner_text.should match(/#{@lister.full_name}/)
    @doc.at('div[@id = "spot_market_seller_info"]').inner_text.should match(/#{@lister.dealership.name}/)
  end
end

describe SpotMarketHelper, "#spot_market_active_offer" do
  it_should_behave_like "setup"

  it "should render nothing if there is no active offer" do
    @prospect.stub!(:active_offer).and_return(nil)
    @doc = Hpricot(spot_market_active_offer(@prospect))

    @doc.at('/').should be_nil
  end

  it "should render details of the active offer, when that exits"
#  TODO: Adding the event fixture for this test caused others to break.
#  it "should render details of the active offer, when that exits" do
#    @prospect.stub!(:active_offer).and_return(events(:offer_event))
#    @doc = Hpricot(spot_market_active_offer(@prospect))
#
#    @doc.at('//div[@id = "spot_market_active_offer"]').should_not be_nil
#    @doc.at('//div[@id = "spot_market_active_offer"]').inner_text.should match(/My current offer Details:/)
#    @doc.at('//div[@id = "spot_market_active_offer"]').inner_text.should match(/\$42,000.00/)
#  end
end

describe SpotMarketHelper, "#spot_market_send_offer" do
  it_should_behave_like "setup"

  it "should render a toggle button labeled 'Make Offer' if no offer has been made"

  it "should render a toggle button labeled 'Improve Offer' if an offer was previously made"

  it "should render a hidden container for the form"
end

describe SpotMarketHelper, "#spot_market_send_message" do
  include ActionController::UrlWriter

  it_should_behave_like "setup"

  it "should render a toggle button labeled 'Send Seller Message (...)' if you are the buyer and the listing is not in your inbox"

  it "should render a toggle button labeled 'New Message' if you are are the buyer and the listing is in your inbox"

  it "should render a hidden container for the form" do
    @doc = Hpricot(spot_market_send_message(@prospect, 'Buyer'))
    @doc.at('//form').parent[:style].should == "display: none;"
  end

  it "should have a message submit form that submits to the ask resource if you are the buyer" do
    @doc = Hpricot(spot_market_send_message(@prospect, 'Buyer'))
    @doc.at('//form')[:action].should =~ /ask$/i
  end

  it "should have a message submit form that submits to the reply resource if you are the seller" do
    @doc = Hpricot(spot_market_send_message(@prospect, 'Seller'))
    @doc.at('//form')[:action].should =~ /reply$/i
  end

  it "should specify that the recipient of the message is the seller, if you are the buyer" do
    @doc = Hpricot(spot_market_send_message(@prospect, 'Buyer'))
    @doc.at('//h4').inner_html.should =~ /#{@lister.full_name}/
  end

  it "should specify that the recipient of the message is the buyer, if you are the seller" do
    @doc = Hpricot(spot_market_send_message(@prospect, 'Seller'))
    @doc.at('//h4').inner_html.should =~ /#{@buyer.full_name}/
  end
end

describe SpotMarketHelper, "#spot_market_event_history" do
  it_should_behave_like "setup"
end
