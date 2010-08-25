require File.dirname(__FILE__) + '/../spec_helper'

describe ReplyEventsController, " handling POST /prospects/x/replies" do

  before :each do
    @user = users(:bob)
    log_in(@user)
  end

  it "should create a new ReplyEvent" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing
    message = 'Excellent!'

    post :create,
         :event => {:comment => message},
         :prospect_id => prospect.id

    response.should be_redirect

    prospect.events.last.class.should   == ReplyEvent
    prospect.events.last.comment.should == message
    listing.events.last.class.should    == ReplyEvent
    listing.events.last.comment.should  == message
  end

end
