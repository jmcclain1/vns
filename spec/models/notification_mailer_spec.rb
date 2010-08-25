require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationMailer do
  include EmailHelper
  
  it "can send an offer received e-mail" do
    charlie  = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.0')

    NotificationMailer.deliver_offer_received(offer, :to => 'bob@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'bob@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Offer Received'
    email.body.should    == offer_received_body(offer)
  end

  it "can send a listing expired e-mail" do
    listing = listings(:bobs_listing_1)

    NotificationMailer.deliver_listing_expired(listing, :to => 'bob@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'bob@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Listing Expired'
    email.body.should    == listing_expired_body(listing)
  end

  it "can send an ask e-mail" do
    charlie  = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    ask = AskEvent.create(:originator => charlie, :prospect => prospect, :comment => "hi bob")
    
    NotificationMailer.deliver_ask(ask, :to => 'bob@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'bob@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Inquiry Received'
    email.body.should    == ask_body(ask)
  end
  
  it "can send a reply e-mail" do
    bob      = users(:bob)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    reply = ReplyEvent.create(:originator => bob, :prospect => prospect, :comment => "hi back, charlie")
    
    NotificationMailer.deliver_reply(reply, :to => 'charlie@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'charlie@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Reply Received'
    email.body.should    == reply_body(reply)
  end
  
  it "can send an auction won e-mail" do
    bob      = users(:bob)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    won = WonEvent.create(:originator => bob, :prospect => prospect)
    
    NotificationMailer.deliver_won(won, :to => 'charlie@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'charlie@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Auction Won'
    email.body.should    == won_body(won)
  end
  
  it "can send an auction lost e-mail" do
    bob      = users(:bob)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    lost = LostEvent.create(:originator => bob, :prospect => prospect)
    
    NotificationMailer.deliver_lost(lost, :to => 'charlie@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'charlie@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Auction Lost'
    email.body.should    == lost_body(lost)
  end
  
  it "can send an auction cancel e-mail" do
    bob      = users(:bob)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    cancel = CancelEvent.create(:originator => bob, :prospect => prospect)
    
    NotificationMailer.deliver_cancel(cancel, :to => 'charlie@foo.com')
    email = ActionMailer::Base.deliveries.last
    email.to[0].should   == 'charlie@foo.com'
    email.from[0].should == 'notify@vnscorporation.com'
    email.subject.should == 'VNS - Auction Cancelled'
    email.body.should    == cancel_body(cancel)
  end
end
