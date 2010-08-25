require File.dirname(__FILE__) + '/../spec_helper'

describe AskEvent do

  it "should have a comment" do
    event = AskEvent.create

    event.should have(1).error_on(:comment)    
  end
  
  it "should send an SMS inquiry message to the seller if the seller wants one" do
    @bob = users(:bob)
    @bob.sms_receive_inquiry.should == true
    @charlie  = users(:charlie)
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @event = AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => 'hiya bob')

    sms = ActionMailer::Base.deliveries.last
    sms.to.size.should == 1
    sms.to[0].should == @bob.sms_address
  end
end
