require File.dirname(__FILE__) + '/../spec_helper'

describe AcceptEventsController, " handling POST /prospects/x/accepts" do

  before :each do
    @user = users(:bob)
    log_in(@user)
  end

  it "should create WonEvents and LostEvents" do

    winning_prospect = prospects(:charlies_interested_in_bobs_listing_1)
    losing_prospect  = prospects(:rob_interested_in_bobs_listing_1)
    message = 'Yours!'

    OfferEvent.create(:originator => users(:charlie), :prospect => winning_prospect, :amount => 1000)

    post :create,
         :event => {:comment => message},
         :prospect_id => winning_prospect.id,
         :agree_to_terms => true

    response.should be_redirect
    winning_prospect.winning_offer.should_not be_nil
  end

end
