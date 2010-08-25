require File.dirname(__FILE__) + '/../spec_helper'

describe CancelEventsController, " handling POST /listings/x/cancels" do

  before :each do
    @user = users(:bob)
    log_in(@user)
  end

  it "should create a new CancelEvent" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing
    message = 'Joe Sucker walked on the lot!'

    post :create,
         :event => {:comment => message},
         :listing_id => listing.id

    response.should be_redirect

    prospect.events.last.class.should   == CancelEvent
    prospect.events.last.comment.should == message
    listing.events.last.class.should    == CancelEvent
    listing.events.last.comment.should  == message
  end

end
