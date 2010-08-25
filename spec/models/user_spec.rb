require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'with notifications' do

  before :each do
    @alice   = users(:alice)
    @bob     = users(:bob)
    @charlie = users(:charlie)
    # create a bunch of Events (which cause Notifications to be created)
    @prospect_1 = prospects(:charlies_interested_in_bobs_listing_1)
    @listing_1 = @prospect_1.listing
    AskEvent.create(:originator => @charlie, :prospect => @prospect_1, :comment => "Is that a VW?")
    AskEvent.create(:originator => @charlie, :prospect => @prospect_1, :comment => "Is that green?")
    ReplyEvent.create(:originator => @bob,   :prospect => @prospect_1, :comment => "Re - Is that a VW?")
    ReplyEvent.create(:originator => @bob,   :prospect => @prospect_1, :comment => "Re - Is that green?")
    @prospect_2 = prospects(:charlies_interested_in_alices_listing_1)
    @listing_2 = @prospect_2.listing
    AskEvent.create(:originator => @charlie, :prospect => @prospect_2, :comment => "To alice from charlie?")
    ReplyEvent.create(:originator => @alice, :prospect => @prospect_2, :comment => "Re - To alice from charlie?")
  end

  it "can return a count of Prospects to display on the Buying tab" do
    @charlie.count_for_buying_tab.should == @charlie.dealership.count_for_buying_tab
  end
  
  it "can return a count of Listings to display on the Selling tab" do
    @bob.count_for_selling_tab.should == @bob.dealership.count_for_selling_tab
  end

  it "can return the Prospects that have alerted notifications" do
    @charlie.prospects_with_alerted_notifications.size.should == 2 # count of Prospects, not count of Notifications
    @charlie.prospects_with_alerted_notifications.should include(@prospect_1)
    @charlie.prospects_with_alerted_notifications.should include(@prospect_2)
  end

  it "can return the Listings that have alerted notifications" do
    @alice.listings_with_alerted_notifications.size.should == 1
    @alice.listings_with_alerted_notifications.should include(@listing_2)
    @bob.listings_with_alerted_notifications.size.should == 1
    @bob.listings_with_alerted_notifications.should include(@listing_1)
  end

end

describe User, 'with a new Partnership' do
  before :each do
    @charlie = users(:charlie)
    @bob = users(:bob)
  end

  it "makes the receiver a partner of the inviter" do
    Partnership.create!(:inviter => @charlie, :receiver => @bob,
                        :accepted => false)

    @charlie.partners.should include(@bob)
  end

  it "makes both parties partners if the receiver accepts the invitation" do
    p = Partnership.create!(:inviter => @charlie, :receiver => @bob,
                        :accepted => false)
    @bob.partners.should_not include(@charlie)

    p.update_attribute(:accepted, true)

    @bob.reload
    @bob.partners.should include(@charlie)
  end
end

describe User, 'setting and updating user information' do
  it "can have a location through its dealership" do
    users(:bob).location.should == users(:bob).dealership.location
  end

  it "has a default status of 'Inactive'" do
    u = User.new
    u.save(false)
    u.status.should == 'inactive'
  end

  it "can assume an active and expired status" do
    u = User.new(:status => 'active')
    u.valid?
    u.should_not have(:any).errors_on(:status)

    u.status = 'expired'
    u.valid?
    u.should_not have(:any).errors_on(:status)
  end

  it "does not allow non-valid statuses" do
    u = users(:bob)
    u.status = 'invalid'

    u.valid?
    u.should have(1).errors_on(:status)
  end

  it "can be associated with a dealership" do
    users(:bob).dealership.should == dealerships(:valid_dealership_1)
  end

  it "can have associated shopping items" do
    charlie = users(:charlie)
    dealership = charlie.dealership
    item = ShoppingItem.create(:originator => charlie, :min_year => 2000, :max_year => 2000)
    charlie.shopping_items.should == [item]
  end

  it "should be able to have an SMS address" do
    bob = users(:bob)
    bob.sms_address.should == "9091231234@vtext.com"
    bob.sms_address = '4327842343@sprint.com'
    bob.sms_address.should == '4327842343@sprint.com'
  end

  it "should be able to specify whether to receive SMS mails" do
    bob = users(:bob)
    bob.sms_wants_new_offer.should == true
    bob.sms_wants_listing_expired.should == false
  end

  it "should not allow invalid SMS addresses" do
    bob = users(:bob)
    bob.sms_address = '43243432432'
    bob.save.should == false
    bob.errors[:sms_address].should =~ /(SMS address).+(is not valid)/
  end

  it "should required SMS addresses have 10 digits before the @" do
    bob = users(:bob)
    bob.sms_address = '4444444@example.com'
    bob.save.should == false
    bob.errors[:sms_address].should =~ /(SMS address).+(is not valid)/
  end

  it "should allow the user to set a blank SMS address" do
    bob = users(:bob)
    bob.sms_address = ''
    bob.save.should == true
  end

  it "should disable all SMS notifications if the user turned off global sms wants flag" do
    bob = users(:bob)
    bob.sms_wants_new_offer = true
    bob.sms_wants_listing_expired = true
    bob.sms_wants_any_sms = false
    bob.sms_receive_new_offer.should == false
    bob.sms_receive_listing_expired.should == false
  end

  it "should disable all SMS notifications if the user has not specified a valid SMS address" do
    bob = users(:bob)
    bob.sms_wants_new_offer = true
    bob.sms_wants_listing_expired = true
    bob.sms_address = ''
    bob.sms_receive_new_offer.should == false
    bob.sms_receive_listing_expired.should == false
  end
  
  it "should handle all of the sms message preferences" do
    bob = users(:bob)
    bob.sms_wants_any_sms.should == true
    bob.sms_wants_new_offer.should == true
    bob.sms_wants_listing_expired.should == false
    bob.sms_wants_inquiry.should == true
    bob.sms_wants_reply.should == false
    bob.sms_wants_auction_won.should == false
    bob.sms_wants_auction_lost.should == false
    bob.sms_wants_auction_cancel.should == false
  end
end

describe User, "#distance_from" do
  it "returns the distance from a given user" do
    users(:bob).distance_from(users(:charlie)).should == users(:bob).dealership.location.distance_from(users(:charlie).dealership.location)
  end
end