require File.dirname(__FILE__) + '/../spec_helper'

describe ProspectsController do
  it "returns all prospects that the user is interested in" do
    charlie = users(:charlie)
    log_in(charlie)

    pre_prospect_count = charlie.prospects.size

    boring_prospect = charlie.prospects.first
    boring_prospect.lose_interest

    xhr :get, :index, {:get_total => 'true', :offset => 0}

    returned_prospects = assigns[:prospects]
    returned_prospects.should_not include(boring_prospect)
    returned_prospects.size.should == pre_prospect_count-1
  end

  it "can return a list of listings that are not owned by the current user's dealership and for which we don't already have a prospect" do
    log_in(users(:bob))
    xhr :get, :new, {:get_total => 'true'}
    listings = assigns[:listings]
    listings[0].lister.should == users(:rob)
  end

  it "should sort prospects by distance" do
    log_in(users(:rob))
    
    xhr :get, :index, {:get_total => 'true', :s3 => 'ASC'}
    assigns[:prospects].should == [prospects(:rob_interested_in_bobs_listing_1), prospects(:rob_interested_in_jetta_listing_2)]

    xhr :get, :index, {:get_total => 'true', :s3 => 'DESC'}
    assigns[:prospects].should == [prospects(:rob_interested_in_jetta_listing_2), prospects(:rob_interested_in_bobs_listing_1)]
  end

  it "can watch a listing" do
    log_in(users(:bob))
    listing = listings(:jetta_listing_2)
    lambda do
      post :create, :listing_id => listing
    end.should change(users(:bob).prospects, :count).by(1)
  end
  
  it "can preview a listing" do
    log_in(users(:bob))
    listing = listings(:jetta_listing_2)
    lambda do
      post :preview, :listing_id => listing
    end.should change(users(:bob).prospects, :count).by(1)
    
    prospect = users(:bob).prospects.find_by_listing_id(listing.id)
    prospect.lost_interest.should be_true
  end
  
  it "marks the preview as a prospect upon message or offer" do
    log_in(users(:bob))
    listing = listings(:jetta_listing_2)
    
    post :preview, :listing_id => listing
    
    prospect = users(:bob).prospects.find_by_listing_id(listing.id)
    prospect.lost_interest.should be_true
    
    AskEvent.create(:originator => users(:bob),   :prospect => prospect, :comment => "Don't you just love cars?")  
    prospect.lost_interest.should be_false
    
    prospect.lose_interest
    prospect.lost_interest.should be_true
    
    ReplyEvent.create(:originator => users(:charlie),   :prospect => prospect, :comment => "I do love cars.") 
    prospect.lost_interest.should be_false
  end

  it "won't add another watch to something you're already watching" do
    log_in(users(:charlie))
    listing = listings(:bobs_listing_1)
    lambda do
      post :create, :listing_id => listing
    end.should change(users(:charlie).prospects, :count).by(0)
  end

  it "re-uses the existing prospect if the user regains interest in the prospect" do
    listing = listings(:bobs_listing_1)
    charlie = users(:charlie)
    log_in(charlie)

    prospect = charlie.prospects.find_by_listing_id(listing.id)
    prospect.lose_interest

    lambda do
      post :create, :listing_id => listing
    end.should change(users(:charlie).prospects, :count).by(0)

    prospect.reload
    prospect.lost_interest.should be_false
  end

  it "marks as prospect as boring on destroy" do
    listing = listings(:bobs_listing_1)
    charlie = users(:charlie)
    log_in(charlie)
    session[:tablist] = {}

    prospect = charlie.prospects.find_by_listing_id(listing.id)

    lambda do
      post :destroy, :id => prospect.id
    end.should change(users(:charlie).prospects, :count).by(0)

    prospect.reload
    prospect.lost_interest.should be_true
  end
end

describe ProspectsController, 'with notifications' do

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

  it "should mark buying messages for a prospect as read when viewing the prospect" do
    log_in(users(:charlie))
    lambda {
      get :show, :id => prospects(:charlies_interested_in_bobs_listing_1)
    }.should change { users(:charlie).prospects_with_alerted_notifications.size }.by(-1)
  end

end
