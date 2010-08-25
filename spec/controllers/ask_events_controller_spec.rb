require File.dirname(__FILE__) + '/../spec_helper'

describe AskEventsController, " handling POST /prospects/x/asks" do

  before :each do
    @user = users(:charlie)
    log_in(@user)
  end

  it "should create a new AskEvent" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing
    message = 'Cowabunga, Dude!'

    post :create,
         :event => {:comment => message},
         :prospect_id => prospect.id

    response.should be_redirect

    prospect.events.last.class.should   == AskEvent
    prospect.events.last.comment.should == message
    listing.events.last.class.should    == AskEvent
    listing.events.last.comment.should  == message
  end

end
