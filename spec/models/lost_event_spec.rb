require File.dirname(__FILE__) + '/../spec_helper'

describe LostEvent do

  it "should send an SMS lost message to the buyer if the buyer wants one" do
    @bob = users(:bob)
    @charlie  = users(:charlie)
    @charlie.sms_wants_auction_lost = true
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @event = LostEvent.create(:originator => @bob, :prospect => @prospect)

    @charlie.sms_receive_auction_lost.should == true

    sms = ActionMailer::Base.deliveries.last
    sms.to.size.should == 1
    sms.to[0].should == @charlie.sms_address
  end
end
