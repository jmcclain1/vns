require File.dirname(__FILE__) + '/../spec_helper'

describe ReplyEvent do

  it "should have a comment" do
    event = ReplyEvent.create

    event.should have(1).error_on(:comment)
  end

  it "should send an SMS reply message to the buyer if the seller wants one" do
    @bob = users(:bob)
    @charlie  = users(:charlie)
    @charlie.sms_wants_reply = true
    @charlie.sms_receive_reply.should == true
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @event = ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => 'hiya charlie')

    sms = ActionMailer::Base.deliveries.last
    sms.to.size.should == 1
    sms.to[0].should == @charlie.sms_address
  end
end
