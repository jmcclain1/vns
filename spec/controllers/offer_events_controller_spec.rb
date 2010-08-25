require File.dirname(__FILE__) + '/../spec_helper'

describe OfferEventsController, " handling POST /prospects/x/offers" do

  before :each do
    @user = users(:charlie)
    log_in(@user)
  end

  it "should create a new OfferEvent" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing
    message = 'Cowabunga, Dude!'
    amount = '1.95'

    post :create,
         :event => {:comment => message, :amount => amount},
         :prospect_id => prospect.id,
         :agree_to_terms => true

    response.should redirect_to(prospect_messages_path(prospect))

    prospect.events.last.class.should       == OfferEvent
    prospect.events.last.comment.should     == message
    prospect.events.last.amount.to_s.should == amount
    listing.events.last.class.should        == OfferEvent
    listing.events.last.comment.should      == message
    listing.events.last.amount.to_s.should  == amount
  end

  it "should display an error if improved offer amount is less than current offer" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing
    current_amount = '2.0'
    current_offer  = OfferEvent.create(:originator => users(:charlie), :prospect => prospect, :amount => current_amount)
    smaller_amount = '1.95'

    post :create,
         :event => {:amount => smaller_amount},
         :prospect_id => prospect.id

    response.should redirect_to(prospect_messages_path(:id => prospect.id, :panel => 'offer'))

    prospect.events.last.class.should           == OfferEvent
    prospect.events.last.amount.to_s.should     == current_amount
    prospect.events.last.amount.to_s.should_not == smaller_amount
    listing.events.last.class.should            == OfferEvent
    listing.events.last.amount.to_s.should      == current_amount
    listing.events.last.amount.to_s.should_not  == smaller_amount
  end

end
