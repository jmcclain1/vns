require File.dirname(__FILE__) + '/../spec_helper'

describe Listing do
  before(:each) do
    @vehicle = create_vehicle
  end

  it "is valid if all required fields exist" do
    listings(:bobs_listing_1).valid?.should == true
  end

  it "must have a vehicle and asking price associated with it" do
    l = Listing.new
    l.should have(1).error_on(:vehicle)
    l.should have(1).errors_on(:asking_price)
    l.should have(1).errors_on(:lister)

    l.vehicle = @vehicle
    l.vehicle.should == @vehicle
  end

  it "can be assigned a lister" do
    bob = users(:bob)
    listing = Listing.new(
      :asking_price => "1.99",
      :vehicle   => @vehicle,
      :dealership => bob.dealership,
      :accept_trade_rules => true
    )
    listing.lister.should == nil

    listing.lister = bob
    listing.save!

    listing.lister.should == bob
  end

  it "returns a list of observers that, for the time being, comprises only the lister" do
    bob = users(:bob)
    listing = Listing.new(
      :asking_price => "1.99",
      :vehicle   => @vehicle,
      :dealership => bob.dealership,
      :accept_trade_rules => true
    )
    listing.observers.should == []

    listing.lister = bob
    listing.save!

    listing.observers.should == [bob]
  end

  it "is a draft when first created" do
    listing = Listing.create
    listing.draft?.should be_true
  end

  it "has a list of recipients" do
    bob = users(:bob)
    alice = users(:alice)
    listing = listings(:pivotal_listing_3)  # this one is by Rob
    listing.recipients.should == []
      listing.recipients << bob
    listing.recipients << alice
    listing.recipients.should == [bob, alice]
  end

  it "can find the listing associated with a given prospect_id" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)

    Listing.for_prospect_id(prospect.id).first.should == prospect.listing
  end

  it "can generate won/lost events when accepted" do
    bob = users(:bob)
    cathy = users(:cathy)
    charlie = users(:charlie)
    comment = "Schwing!"
    prospect_1 = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect_1.listing
    prospect_2 = Prospect.create(:listing => listing, :dealership => cathy.dealership, :prospector => cathy)
    offer    = OfferEvent.create(:originator => charlie, :prospect => prospect_1, :amount => '91.69')

    listing.accept(prospect_1,{:originator => bob, :comment => comment})

    prospect_1.reload
    prospect_1.events.first.class.should == WonEvent
    prospect_1.events.first.comment.should == comment

    prospect_2.reload
    prospect_2.events.first.class.should == LostEvent
    prospect_2.events.first.comment.should be_nil
  end

  it "can generate cancel events for all prospects when cancelled" do
    bob = users(:bob)
    cathy = users(:cathy)
    charlie = users(:charlie)
    comment = "Zap!"
    prospect_1 = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect_1.listing
    prospect_2 = Prospect.create(:listing => listing, :dealership => cathy.dealership, :prospector => cathy)

    listing.cancel({:originator => bob, :comment => comment})

    prospect_1.events.last.class.should == CancelEvent
    prospect_1.events.last.comment.should == comment

    prospect_2.events.last.class.should == CancelEvent
    prospect_2.events.last.comment.should == comment
  end

  it "can find all listings that are unwatched by the current user" do
    charlie = users(:charlie)
    boring_prospect = charlie.prospects.first

    Listing.unwatched_by(charlie.dealership.id).should_not include(boring_prospect.listing)

    boring_prospect.lose_interest

    Listing.unwatched_by(charlie.dealership.id).should include(boring_prospect.listing)
  end

  it "includes listing in #paginate_for_search that the user has a prospect for, but has lost interest in" do
    charlie = users(:charlie)
    boring_prospect = charlie.prospects.first

    Listing.paginate_for_search(:user => charlie).should_not include(boring_prospect.listing)

    boring_prospect.lose_interest

    Listing.paginate_for_search(:user => charlie).should include(boring_prospect.listing)
  end
  
  private
  def create_listing_for(lister, vehicle)
    Listing.create(
      :asking_price => "1.99",
      :vehicle   => vehicle,
      :lister => lister,
      :dealership => lister.dealership,
      :state => 'draft',
      :accept_trade_rules => true
    )
  end

  def create_vehicle
    Vehicle.create(
      :trim_id     => "123",
      :vin          => "01234567890123456",
      :odometer     => 555666,
      :actual_cash_value => 123.00,
      :cost => 2000.00,
      :certified    => true,
      :frame_damage => false,
      :prior_paint  => false
    )
  end
end

describe Listing, "pagination and sorting" do
  it "can paginate listings in order" do
    bob = users(:bob)
    listings = Listing.paginate(:user => bob)
    listings.should == [listings(:alices_listing_1), listings(:bobs_listing_1)]
  end

  it "can paginate listings by last activity when there are no events" do
    bob = users(:bob)
    listings = Listing.paginate(:user => bob, :s4 => "DESC")
    listings.should == [listings(:alices_listing_1), listings(:bobs_listing_1)]
  end

  it "can paginate listings by last activity when there is one event" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    AskEvent.create(:originator => users(:charlie), :prospect => prospect, :comment => "a comment")

    listings = Listing.paginate(:user => users(:bob), :s4 => "DESC")
    listings.should == [listings(:bobs_listing_1), listings(:alices_listing_1)]
  end

  it "can paginate listings by last activity when there are many events" do
    bob = users(:bob)

    AskEvent.create(:originator => users(:charlie), :prospect => prospects(:charlies_interested_in_bobs_listing_1), :comment => "a comment")
    AskEvent.create(:originator => users(:charlie), :prospect => prospects(:charlies_interested_in_alices_listing_1), :comment => "a comment")

    listings = Listing.paginate(:user => bob, :s4 => "DESC")
    listings.should == [listings(:alices_listing_1), listings(:bobs_listing_1)]
  end
end

describe Listing, "state" do
  before do
  end

  it "can mark all listings that have expired as state=>expired" do
    bobs_listing_that_is_NOT_expired = listings(:bobs_listing_1)
    pivotals_listing_that_IS_expired = listings(:pivotal_listing_1)
    alices_listing_that_DID_expire_just_a_few_minutes_earlier = listings(:alices_listing_1)

    bobs_listing_that_is_NOT_expired.update_attributes(:auction_start => 1.day.ago, :auction_duration => 30)
    pivotals_listing_that_IS_expired.update_attributes(:auction_start => 10.day.ago, :auction_duration => 1)
    alices_listing_that_DID_expire_just_a_few_minutes_earlier.update_attributes(:auction_start => (1.day.ago-1.minute), :auction_duration => 1)
    bobs_listing_that_is_NOT_expired.should_not be_expired
    pivotals_listing_that_IS_expired.should_not be_expired
    alices_listing_that_DID_expire_just_a_few_minutes_earlier.should_not be_expired

    Listing.expire_listings

    bobs_listing_that_is_NOT_expired.reload
    pivotals_listing_that_IS_expired.reload
    alices_listing_that_DID_expire_just_a_few_minutes_earlier.reload
    bobs_listing_that_is_NOT_expired.should_not be_expired
    pivotals_listing_that_IS_expired.should be_expired
    alices_listing_that_DID_expire_just_a_few_minutes_earlier.should be_expired
  end

  it "recognizes drafts" do
    listings(:draft_listing_1).state.should == :draft
    listings(:bobs_listing_1).state.should_not == :draft
  end

  it "recognizes unstarted listings" do
    listing = listings(:bobs_listing_1)
    Time.stub!(:now).and_return(listing.auction_start - 1.day)
    listing.state.should == :unstarted
  end

  it "recognizes active listings" do
    listing = listings(:bobs_listing_1)
    Time.stub!(:now).and_return(listing.auction_start + 12.hours)
    listing.state.should == :active
  end

  it "recognizes expired listings by their expired flag" do
    listing = listings(:bobs_listing_1)
    listing.update_attribute(:auction_start, Time.now() - 25.days)
    Listing.expire_listings

    listing.reload
    listing.state.should == :expired
  end

  it "recognizes listings expired via #expire" do
    listing = listings(:bobs_listing_1)
    listing.stub!(:auction_start).and_return(Time.now()-1)
    listing.stub!(:auction_duration).and_return(1)
    listing.expire
    listing.state.should == :expired
  end

  it "recognizes published listings as active" do
    listing = listings(:bobs_listing_1)
    listing.stub!(:auction_start).and_return(Time.now()-1)
    listing.stub!(:auction_duration).and_return(1)
    listing.publish
    listing.state.should == :active
  end

  it "recognizes cancelled listings" do
    listing = listings(:bobs_listing_1)
    listing.cancel(:originator => users(:bob))
    listing.state.should == :canceled
  end

  it "recognizes sold listings" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer    = OfferEvent.create(:originator => users(:charlie), :prospect => prospect, :amount => '9900')
    listing  = prospect.listing
    listing.accept(prospect, :originator => users(:bob))
    listing.state.should == :pending
  end

  it "recognizes completed listings" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing  = prospect.listing
    offer    = OfferEvent.create(:originator => users(:charlie), :prospect => prospect, :amount => '9900')
    listing.accept(prospect, :originator => users(:bob))
    listing.complete_sale
    listing.state.should == :completed
  end
end

describe Listing, "#high_offer" do
  it "returns nil if there are no offers" do
    listings(:bobs_listing_1).high_offer.should be_nil
  end

  it "returns the high offer" do
    bob = users(:bob)
    charlie = users(:charlie)
    listings(:bobs_listing_1)

    offer_from_rob = OfferEvent.create(:prospect => prospects(:rob_interested_in_bobs_listing_1), :originator => users(:rob), :amount => 15000)
    offer_from_charlie = OfferEvent.create(:prospect => prospects(:charlies_interested_in_bobs_listing_1), :originator => users(:charlie), :amount => 10000)

    listings(:bobs_listing_1).high_offer.should_not be_nil
    listings(:bobs_listing_1).high_offer.amount.should == 15000
  end
end

describe Listing, "#publish" do

  it "creates a prospect for each recipient" do
    cathy   = users(:cathy)
    charlie = users(:charlie)
    listing = listings(:bobs_listing_1)
    listing.recipients << cathy
    listing.recipients << charlie

    listing.publish
    cathy.prospects.first.listing.should   == listing
    charlie.prospects.first.listing.should == listing
  end

end

describe Listing, "accepting and completing" do

  before do
    @charlie  = users(:charlie)
    @bob      = users(:bob)
    @prospect = prospects(:charlies_interested_in_bobs_listing_1)
    @offer    = OfferEvent.create(:originator => @charlie, :prospect => @prospect, :amount => '1.69')
    @listing  = @prospect.listing
    @vehicle = @listing.vehicle
  end

  it "#accept marks a prospect as the winner" do
    @listing.winning_prospect.should == nil
    @listing.accept(@prospect, :originator => @bob)
    @listing.winning_prospect.should == @prospect
    @listing.reload
    @listing.winning_prospect.should == @prospect
  end

  it "should create WonEvents and LostEvents" do
    winning_prospect = @prospect
    losing_prospect  = prospects(:rob_interested_in_bobs_listing_1)
    message = 'Yours!'

    @listing.accept(winning_prospect, {:comment => message, :originator => @bob})

    winning_prospect.reload
    winning_event = winning_prospect.events.first
    winning_event.class.should   == WonEvent
    winning_event.comment.should == message
    winning_event.amount.should == winning_prospect.winning_offer.amount

    losing_prospect.reload
    losing_event = losing_prospect.events.first
    losing_event.class.should    == LostEvent
    losing_event.comment.should  be_nil
  end

  it "#complete_sale copies a completed listing into the buyer's inventory" do
    selling_dealership = dealerships(:valid_dealership_1)
    buying_dealership = dealerships(:valid_dealership_2)
    vin = @vehicle.vin

    @vehicle.dealership.should == selling_dealership

    @listing.accept(@prospect, :originator => @bob)
    @listing.complete_sale
    @listing.state.should == :completed

    @vehicle.reload
    @vehicle.dealership.should == nil

    buying_dealership.reload
    selling_dealership.reload
    twin = buying_dealership.vehicles.find_by_vin(vin)
    twin.should_not be_nil
    twin.cost.should == @listing.winning_prospect.winning_offer.amount
  end
end

describe Listing, "#auction_start" do
  it "defaults to Time.now until it's been set" do
    sometime = Time.local(2000, 10, 9, 8, 7, 6)
    listing = Listing.new
    listing.auction_start.should == Clock.now

    Clock.tick(1.hour)
    listing.auction_start.should == Clock.now

    listing.auction_start = sometime
    listing.auction_start.should == sometime
  end

  it "gets set to Time.now on publish" # do
#    This test fails because it creates a listing without a vehicle, fix it
#    listing = Listing.new(:dealership => dealerships(:valid_dealership_1))
#    
#    time_when_published = Clock.now
#    listing.publish
#    listing.auction_start.should == time_when_published
#
#    Clock.tick(1.hour)
#    listing.auction_start.should == time_when_published
#  end

  it "does not include closed listings in count for find vehicles" do
    rob = users(:rob)
    alices_listing = listings(:alices_listing_1)
    charlie = users(:charlie)
    charlies_prospect = prospects(:charlies_interested_in_alices_listing_1)
    charlies_offer    = OfferEvent.create(:originator => charlie, :prospect => charlies_prospect, :amount => '1.69')

    rob_potential_buys = Listing.paginate_for_search(:user => rob)
    rob_potential_buys.should_not be_nil
    rob_potential_buys.should include(alices_listing)
    rob_count = rob_potential_buys.size
    Listing.count_for_search(:user => rob).should == rob_count

    lambda {
      alices_listing.accept(charlies_prospect, :originator => users(:alice))
      alices_listing.reload
    }.should change {Listing.count_for_search(:user => rob)}.by(-1)
    
    rob_potential_buys = Listing.paginate_for_search(:user => rob)
    rob_potential_buys.should_not be_nil
    rob_potential_buys.should_not include(alices_listing)
  end

describe Listing, "filters" do

  before do
    @rob = users(:rob)
    @count_buys_before = Listing.count_for_search(:user => @rob)
    potential_buys_before = Listing.paginate_for_search(:user => @rob)
    potential_buys_before.should_not be_nil
    @filter_me_out = potential_buys_before[0]
  end
  
  it "can filter on max odometer" do
    count_buys_after = Listing.count_for_search(:user => @rob, :filter => {:max_odometer => (@filter_me_out.vehicle.odometer - 1)})
    count_buys_after.should < @count_buys_before
    potential_buys_after = Listing.paginate_for_search(:user => @rob, :filter => {:max_odometer => (@filter_me_out.vehicle.odometer - 1)})
    potential_buys_after.should_not include(@filter_me_out)
  end

  it "can filter on max price" do
    count_buys_after = Listing.count_for_search(:user => @rob, :filter => {:max_price => (@filter_me_out.asking_price - 1)})
    count_buys_after.should < @count_buys_before
    potential_buys_after = Listing.paginate_for_search(:user => @rob, :filter => {:max_price => (@filter_me_out.asking_price - 1)})
    potential_buys_after.should_not include(@filter_me_out)
  end

  it "can filter on max distance" do
    distance = 1 #hack, 
    count_buys_after = Listing.count_for_search(:user => @rob, :dealership => @rob.dealership, :filter => {:max_distance => distance})
    count_buys_after.should < @count_buys_before
    potential_buys_after = Listing.paginate_for_search(:user => @rob, :dealership => @rob.dealership, :filter => {:max_distance => distance})
    potential_buys_after.should_not include(@filter_me_out)
  end

  it "can filter on min year" do
    count_buys_after = Listing.count_for_search(:user => @rob, :filter => {:min_year => (@filter_me_out.vehicle.year + 1)})
    count_buys_after.should < @count_buys_before
    potential_buys_after = Listing.paginate_for_search(:user => @rob, :filter => {:min_year => (@filter_me_out.vehicle.year + 1)})
    potential_buys_after.should_not include(@filter_me_out)
  end

  it "can filter on max year" do
    count_buys_after = Listing.count_for_search(:user => @rob, :filter => {:max_year => (@filter_me_out.vehicle.year - 1)})
    count_buys_after.should < @count_buys_before
    potential_buys_after = Listing.paginate_for_search(:user => @rob, :filter => {:max_year => (@filter_me_out.vehicle.year - 1)})
    potential_buys_after.should_not include(@filter_me_out)
  end

end

end