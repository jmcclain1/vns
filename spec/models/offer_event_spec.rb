require File.dirname(__FILE__) + '/../spec_helper'

describe OfferEvent, "create new" do

  it "should have an offer amount" do
    event = OfferEvent.create

    event.should have(1).errors_on(:amount)    
  end

  it "should not have a blank offer amount" do
    event = OfferEvent.create(:amount => '')

    event.should have(1).errors_on(:amount)
  end

  it "must have a numeric amount" do
    event = OfferEvent.create(:amount => 'abc')

    event.should have(1).errors_on(:amount)
  end
end

describe OfferEvent, "offer on prospect" do

  before :each do
    @bob = users(:bob)
    @charlie  = users(:charlie)
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @event = OfferEvent.create(:originator => @charlie, :prospect => @prospect, :amount => '1.0')
  end

  it "can check that an improved offer is more than the current offer" do
    new_event = OfferEvent.create(:originator => @charlie, :prospect => @prospect, :amount => '0.99')
    new_event.should have(1).errors_on(:amount)
  end

  it "should send an SMS to the seller if the seller wants one" do
    @bob.sms_receive_new_offer.should == true

    sms = ActionMailer::Base.deliveries.last
    sms.to.size.should == 1
    sms.to[0].should == @bob.sms_address
  end
end
