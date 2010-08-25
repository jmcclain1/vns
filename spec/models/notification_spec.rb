require File.dirname(__FILE__) + '/../spec_helper'

describe "NotificationSetup", :shared => true do
  before :each do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @rob = users(:rob)
    @rob2 = users(:rob2)
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @listing = @prospect.listing
  end
end

describe Notification, " based on user" do
  it_should_behave_like "NotificationSetup"

  it "requires a recipient and a tradeable (which is either a Listing or a Prospect)" do
    n = Notification.new
    n.valid?

    n.should have(1).error_on(:recipient)
    n.should have(1).error_on(:tradeable)
  end

  it "should have a default status of alerted and unread" do
    n = Notification.new
    n.alerted.should == true
    n.unread.should == true
  end

  it "should generate an as_buyer notification when a buying event is created" do
    lambda {
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "a comment")
    }.should change { @charlie.notifications.active.as_buyer.count }.by(1)
  end

  it "should not generate an as_seller notification when a buying event is created" do
    lambda {
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "a comment")
    }.should_not change { @bob.notifications.active.as_seller.count }
  end

  it "should generate an as_seller notification when a selling event is created" do
    lambda {
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "a comment")
    }.should change { @bob.notifications.active.as_seller.count }.by(1)
  end

  it "should not generate an as_buyer notification when a selling event is created" do
    lambda {
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "a comment")
    }.should_not change { @charlie.notifications.active.as_buyer.count }
  end

  it "can return the list of listings scoped by the has_finder methods" do
    AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "a comment")
    @bob.notifications.active.as_seller.listings.should include(@prospect.listing)
  end

  it "can return the list of prospects scoped by the has_finder methods" do
    ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "a comment")
    @charlie.notifications.active.as_buyer.prospects.should include(@prospect)
  end

  it "should create a seller notification for each event" do
    lambda {
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "Charlie Msg 1")
      AskEvent.create(:originator => @rob,     :prospect => @prospect, :comment => "Rob Msg 1")
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "Charlie Msg 2")
    }.should change { @bob.notifications.active.as_seller.count }.by(3)
  end

  it "should only return one listing when multiple seller notifications apply to that listing" do
    lambda {
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "Charlie Msg 1")
      AskEvent.create(:originator => @rob,     :prospect => @prospect, :comment => "Rob Msg 1")
      AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "Charlie Msg 2")
    }.should change { @bob.notifications.active.as_seller.listings.size }.by(1)
  end

  it "should create a buyer notification for each event" do
    lambda {
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 1")
      ReplyEvent.create(:originator => @rob, :prospect => @prospect, :comment => "Rob Msg 1")
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 2")
    }.should change { @charlie.notifications.active.as_buyer.count }.by(3)
  end

  it "should only return one listing when multiple buyer notifications apply to that listing" do
    lambda {
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 1")
      ReplyEvent.create(:originator => @rob, :prospect => @prospect, :comment => "Rob Msg 1")
      ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 2")
    }.should change { @charlie.notifications.active.as_buyer.prospects.size }.by(1)
  end

end

describe Notification, " based on listing or prospect" do
  it_should_behave_like "NotificationSetup"

  before :each do
    @listing.stub!(:observers).and_return([@bob,@alice]) # fake out (for now) multiple listing observers
    @prospect.stub!(:observers).and_return([@charlie,@rob]) # fake out (for now) multiple prospect observers
  end
  
  it "can scope notifications on a listing/prospect to a particular user" do
     AskEvent.create(:originator => @charlie, :prospect => @prospect, :comment => "Charlie Msg 1")
   
     try_assoc @listing.notifications,  :total => 3, :alice => 1, :bob => 1, :rob2 => 1, :charlie => 0, :rob => 0
     try_assoc @prospect.notifications, :total => 0, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 0, :rob => 0
   end

  it "can scope notifications on a listing/prospect to a particular user ... the REPLY" do
    ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Yes, Charlie")
  
    try_assoc @listing.notifications,  :total => 2, :alice => 1, :bob => 0, :rob2 => 1, :charlie => 0, :rob => 0
    try_assoc @prospect.notifications, :total => 1, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 1, :rob => 0
  end

  it "can distinguish states for notifications on a listing/prospect" do
    reply1 = ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Yes, Charlie")
    reply1.prospect.notifications.for_recipient(@charlie)[0].clear_unread
    #reply1.prospect.notifications.for_recipient(@rob)[0].clear_alerted
    reply1.prospect.listing.notifications.for_recipient(@alice)[0].clear_alerted
  
    reply2 = ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Yes, Charlie")
  
    try_assoc @listing.notifications,          :total => 4, :alice => 2, :bob => 0, :rob2 => 2, :charlie => 0, :rob => 0
    try_assoc @listing.notifications.active,   :total => 4, :alice => 2, :bob => 0, :rob2 => 2, :charlie => 0, :rob => 0
    try_assoc @listing.notifications.alerted,  :total => 1, :alice => 1, :bob => 0, :rob2 => 0, :charlie => 0, :rob => 0
    try_assoc @listing.notifications.unread,   :total => 4, :alice => 2, :bob => 0, :rob2 => 2, :charlie => 0, :rob => 0
  
    try_assoc @prospect.notifications,         :total => 2, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 2, :rob => 0
    try_assoc @prospect.notifications.active,  :total => 1, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 1, :rob => 0
    try_assoc @prospect.notifications.alerted, :total => 1, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 1, :rob => 0
    try_assoc @prospect.notifications.unread,  :total => 1, :alice => 0, :bob => 0, :rob2 => 0, :charlie => 1, :rob => 0
  end
  
  def try_assoc(assoc,options)
    assoc.count.should                          == options[:total]
    assoc.for_recipient(@alice).count.should    == options[:alice]
    assoc.for_recipient(@bob).count.should      == options[:bob]
    assoc.for_recipient(@rob2).count.should     == options[:rob2]
    assoc.for_recipient(@charlie).count.should  == options[:charlie]
    assoc.for_recipient(@rob).count.should      == options[:rob]
  end
end

describe Notification, "#clear_alerted" do
  it_should_behave_like "NotificationSetup"

  it "should only change the count of alerted notifications" do
    ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 1")
    init_count = @charlie.notifications.count

    @charlie.notifications.alerted.last.clear_alerted

    @charlie.notifications.count.should         == init_count
    @charlie.notifications.alerted.count.should == (init_count - 1)
    @charlie.notifications.active.count.should  == init_count
    @charlie.notifications.unread.count.should  == init_count
  end
end

describe Notification, "#clear_unread" do
  it_should_behave_like "NotificationSetup"

  it "should clear the unread flag" do
    ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 1")
    init_count = @charlie.notifications.count

    @charlie.notifications.alerted.last.clear_unread

    @charlie.notifications.unread.count.should  == (init_count - 1)
  end

  it "should clear the alerted flag (thereby inactivating)" do
    ReplyEvent.create(:originator => @bob, :prospect => @prospect, :comment => "Bob Msg 1")
    init_count = @charlie.notifications.count

    @charlie.notifications.alerted.last.clear_unread

    @charlie.notifications.count.should         == init_count
    @charlie.notifications.alerted.count.should == (init_count - 1)
    @charlie.notifications.active.count.should  == (init_count - 1)
  end
end
