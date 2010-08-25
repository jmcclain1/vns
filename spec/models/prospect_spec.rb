require File.dirname(__FILE__) + '/../spec_helper'

describe Prospect do

  it "should be valid" do
    prospects(:charlies_interested_in_bobs_listing_1).should be_valid
  end

  it "must have a dealership, listing, and prospector" do
    prospect = Prospect.create
    prospect.valid?
    prospect.should have(1).errors_on(:dealership)
    prospect.should have(1).errors_on(:listing)
    prospect.should have(1).errors_on(:prospector)
  end

  it "won't allow another prospect to be created with the same listing" do
    p1 = Prospect.create(:dealership => dealerships(:valid_dealership_1),
                         :listing => listings(:jetta_listing_2),
                         :prospector => users(:bob))

    p1.valid?.should == true

    p2 = Prospect.new(:dealership => dealerships(:valid_dealership_1),
                      :listing => listings(:jetta_listing_2),
                      :prospector => users(:alice))
    p2.valid?
    p2.should have(1).errors_on(:listing_id)

    p2.dealership = dealerships(:valid_dealership_2)
    p2.valid?
    p2.should have(:no).errors_on(:dealership_id)
  end

  it "returns a list of observers that, for the time being, comprises only the prospector" do
    bob = users(:bob)
    prospect = Prospect.new(
      :listing    => listings(:jetta_listing_2),
      :dealership => bob.dealership
    )
    prospect.observers.should == []

    prospect.prospector = bob
    prospect.save!

    prospect.observers.should == [bob]
  end

  it "can determine its active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer_1 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.69')
    offer_2 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.79')

    prospect.active_offer.should == offer_2
  end

  it "returns nil if there isn't an active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)

    prospect.active_offer.should == nil
  end

  it "can determine if it is the winning prospect" do
    charlie  = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer    = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.69')
    listing  = prospect.listing
    bob      = users(:bob)
    listing.accept(prospect, :originator => bob)

    prospect.winner?.should == true
  end
end

describe Prospect, "paginating and sorting" do
  it "returns all prospects ordered by year,make,model,id by default" do
    p1, p2, p3 = setup_prospects

    prospects = Prospect.paginate(:user => users(:cathy))
    prospects.size.should == 3
    prospects.first.should == p3
    prospects.last.should == p1
  end

  it "does not return prospects that the user is not interested in anymore" do
    p1, p2, p3 = setup_prospects

    prospects = Prospect.paginate(:user => users(:cathy))
    prospects.should include(p1)

    p1.lose_interest
    prospects = Prospect.paginate(:user => users(:cathy))
    prospects.should_not include(p1)
  end

  it "honors the offset and page_size parameters" do
    p1, p2, p3 = setup_prospects
    prospects = Prospect.paginate(:user => users(:cathy), :offset => 1, :page_size => 2)
    prospects.size.should == 2
    prospects[0].should == p2
    prospects[1].should == p1

    prospects = Prospect.paginate(:user => users(:cathy), :offset => 2, :page_size => 1)
    prospects.size.should == 1
    prospects[0].should == p1
  end

  it "can order by year (s0)" do
    pending('fm - need more model years') do
      p1, p2, p3 = setup_prospects
      prospects = Prospect.paginate(:user => users(:cathy), :s0 => 'ASC')
      prospects.size.should == 3
      prospects[0].should == p2
      prospects[1].should == p3
      prospects[2].should == p1

      prospects = Prospect.paginate(:user => users(:cathy), :s0 => 'DESC')
      prospects.size.should == 3
      prospects[0].should == p3
      prospects[1].should == p1
      prospects[2].should == p2
    end
  end

  it "can order by make/model (s1)" do
    p1, p2, p3 = setup_prospects
    prospects = Prospect.paginate(:user => users(:cathy), :s1 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p1
    prospects[2].should == p2

    prospects = Prospect.paginate(:user => users(:cathy), :s1 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3
  end

  it "can order by mileage" do
    p1, p2, p3 = setup_prospects
    prospects = Prospect.paginate(:user => users(:cathy), :s2 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3

    prospects = Prospect.paginate(:user => users(:cathy), :s2 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p2
    prospects[2].should == p1
  end

  it "can order by distance" do
    prospect_for_big_als, prospect_for_pivotal, prospect_for_bob = setup_prospects_for_distance
    prospects = Prospect.paginate(:user => users(:cathy), :s3 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == prospect_for_bob
    prospects[1].should == prospect_for_big_als
    prospects[2].should == prospect_for_pivotal

    prospects = Prospect.paginate(:user => users(:cathy), :s3 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == prospect_for_pivotal
    prospects[1].should == prospect_for_big_als
    prospects[2].should == prospect_for_bob
  end

  it "can order by asking price" do
    p1, p2, p3 = setup_prospects
    prospects = Prospect.paginate(:user => users(:cathy), :s4 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p2
    prospects[2].should == p1

    prospects = Prospect.paginate(:user => users(:cathy), :s4 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3
  end

  it "can paginate prospects by last activity when there are no events" do
    charlie = users(:charlie)
    page = Prospect.paginate(:user => charlie, :s5 => "DESC")
    page.should == [prospects(:charlies_interested_in_alices_listing_1), prospects(:charlies_interested_in_bobs_listing_1)]
  end

  it "can paginate prospects by last activity when there is one event" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    ReplyEvent.create(:originator => users(:bob), :prospect => prospect, :comment => "a comment")

    page = Prospect.paginate(:user => users(:charlie), :s5 => "DESC")
    page.should == [prospects(:charlies_interested_in_bobs_listing_1), prospects(:charlies_interested_in_alices_listing_1)]
  end

  it "can determine its active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer_1 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.69')
    offer_2 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.79')

    prospect.active_offer.should == offer_2
  end

  it "returns nil if there isn't an active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)

    prospect.active_offer.should == nil
  end
  
  # paginating and sorting for completed listings
  
  it "returns prospects won"
  it "does not return prospects won when listing is not completed"
  it "does not return completed prospects where the current user is not the winner"
  it "returns listings sold"
  it "does not return listings that are not completed yet"

  private
  def add_prospect(args)
    Prospect.create!(:dealership => args[:dealership],
                     :listing => args[:listing],
                     :prospector => args[:prospector])
  end
  def setup_prospects
    dealership = dealerships(:valid_dealership_4)
    cathy = users(:cathy)
    l1 = listings(:pivotal_listing_1)
    l2 = listings(:pivotal_listing_2)
    l3 = listings(:pivotal_listing_3)
    p1 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l1)
    p2 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l2)
    p3 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l3)
    return [p1,p2,p3]
  end

  def setup_prospects_for_distance()
    dealership = dealerships(:valid_dealership_4)
    cathy = users(:cathy)
    l1 = listings(:pivotal_listing_1)
    l2 = listings(:bobs_listing_1)
    l3 = listings(:jetta_listing_2)
    p1 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l1)
    p2 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l2)
    p3 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l3)
    return [p1,p2,p3]
  end
end

describe Prospect, "with livegrid_sort" do
  it "returns all prospects ordered by year,make,model,id by default" do
    p1, p2, p3 = setup_prospects

#    puts "#{p1.listing.vehicle.display_name} #{p1.id}"
#    puts "#{p2.listing.vehicle.display_name} #{p2.id}"
#    puts "#{p3.listing.vehicle.display_name} #{p3.id}"

    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy))
    prospects.size.should == 3
    prospects.first.should == p3
    prospects.last.should == p2
  end

  it "honors the offset and page_size parameters" do
    p1, p2, p3 = setup_prospects
    prospects = users(:cathy).dealership.prospects.livegrid_page(:offset => 1, :page_size => 2).livegrid_sort(:user => users(:cathy))
    prospects.size.should == 2
    prospects[0].should == p1
    prospects[1].should == p2

    prospects = users(:cathy).dealership.prospects.livegrid_page(:offset => 2, :page_size => 1).livegrid_sort(:user => users(:cathy))
    prospects.size.should == 1
    prospects[0].should == p2
  end

  it "can order by year (s0)" do
    pending('fm - need more model years') do
      p1, p2, p3 = setup_prospects
      prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s0 => 'ASC')
      prospects.size.should == 3
      prospects[0].should == p2
      prospects[1].should == p3
      prospects[2].should == p1

      prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s0 => 'DESC')
      prospects.size.should == 3
      prospects[0].should == p3
      prospects[1].should == p1
      prospects[2].should == p2
    end
  end

  it "can order by make/model (s1)" do
    p1, p2, p3 = setup_prospects
    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s1 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p1
    prospects[2].should == p2

    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s1 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3
  end

  it "can order by mileage" do
    p1, p2, p3 = setup_prospects
    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s2 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3

    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s2 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p2
    prospects[2].should == p1
  end

  it "can order by distance" do
    prospect_for_big_als, prospect_for_pivotal, prospect_for_bob = setup_prospects_for_distance
    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s3 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == prospect_for_bob
    prospects[1].should == prospect_for_big_als
    prospects[2].should == prospect_for_pivotal

    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s3 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == prospect_for_pivotal
    prospects[1].should == prospect_for_big_als
    prospects[2].should == prospect_for_bob
  end

  it "can order by asking price" do
    p1, p2, p3 = setup_prospects
    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s4 => 'ASC')
    prospects.size.should == 3
    prospects[0].should == p3
    prospects[1].should == p2
    prospects[2].should == p1

    prospects = users(:cathy).dealership.prospects.livegrid_sort(:user => users(:cathy), :s4 => 'DESC')
    prospects.size.should == 3
    prospects[0].should == p1
    prospects[1].should == p2
    prospects[2].should == p3
  end

  it "can paginate prospects by last activity when there are no events" do
    charlie = users(:charlie)
    page = charlie.dealership.prospects.livegrid_sort(:user => charlie, :s5 => "DESC")
    page.should == [prospects(:charlies_interested_in_alices_listing_1), prospects(:charlies_interested_in_bobs_listing_1)]
  end

  it "can paginate prospects by last activity when there is one event" do
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    ReplyEvent.create(:originator => users(:bob), :prospect => prospect, :comment => "a comment")

    page = users(:charlie).dealership.prospects.livegrid_sort(:user => users(:charlie), :s5 => "DESC")
    page.should == [prospects(:charlies_interested_in_bobs_listing_1), prospects(:charlies_interested_in_alices_listing_1)]
  end

  it "can paginate prospects by last activity when there is more than one event" #do
#    pending("jld - under construction ...") do
#      prospect_1 = prospects(:charlies_interested_in_alices_listing_1)
#      ReplyEvent.create(:originator => users(:alice), :prospect => prospect_1, :comment => "a comment")
#      ReplyEvent.create(:originator => users(:alice), :prospect => prospect_1, :comment => "another comment")
#      prospect_2 = prospects(:charlies_interested_in_bobs_listing_1)
#      ReplyEvent.create(:originator => users(:bob), :prospect => prospect_2, :comment => "a comment")
#      ReplyEvent.create(:originator => users(:bob), :prospect => prospect_2, :comment => "another comment")
#
#      page = users(:charlie).dealership.prospects.livegrid_sort(:user => users(:charlie), :s5 => "DESC")
#      page.size.should == 2
#      page.should == [prospects(:charlies_interested_in_bobs_listing_1), prospects(:charlies_interested_in_alices_listing_1)]
#    end
#  end

  it "can determine its active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer_1 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.69')
    offer_2 = OfferEvent.create(:originator => charlie, :prospect => prospect, :amount => '1.79')

    prospect.active_offer.should == offer_2
  end

  it "returns nil if there isn't an active offer" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)

    prospect.active_offer.should == nil
  end

  private
  def add_prospect(args)
    Prospect.create!(:dealership => args[:dealership],
                     :listing => args[:listing],
                     :prospector => args[:prospector])
  end
  def setup_prospects
    dealership = dealerships(:valid_dealership_4)
    cathy = users(:cathy)
    l1 = listings(:pivotal_listing_1)
    l2 = listings(:pivotal_listing_2)
    l3 = listings(:pivotal_listing_3)
    p1 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l1)
    p2 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l2)
    p3 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l3)
    return [p1,p2,p3]
  end

  def setup_prospects_for_distance()
    dealership = dealerships(:valid_dealership_4)
    cathy = users(:cathy)
    l1 = listings(:pivotal_listing_1)
    l2 = listings(:bobs_listing_1)
    l3 = listings(:jetta_listing_2)
    p1 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l1)
    p2 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l2)
    p3 = add_prospect(:dealership => dealership,
                      :prospector => cathy,
                      :listing => l3)
    return [p1,p2,p3]
  end
end
