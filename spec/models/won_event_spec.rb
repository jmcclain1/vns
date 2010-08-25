require File.dirname(__FILE__) + '/../spec_helper'

describe WonEvent do

  it "should send an SMS won message to the buyer if the buyer wants one" do
    @bob = users(:bob)
    @charlie  = users(:charlie)
    @charlie.sms_wants_auction_won = true
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @event = WonEvent.create(:originator => @bob, :prospect => @prospect)

    @charlie.sms_receive_auction_won.should == true

    sms = ActionMailer::Base.deliveries.last
    sms.to.size.should == 1
    sms.to[0].should == @charlie.sms_address
  end
end
