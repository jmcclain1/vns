require File.dirname(__FILE__) + '/../spec_helper'

describe ListingsController, " showing all listing (#index)" do
  before do
    @user = users(:bob)
    log_in(@user)
  end

  it "should ignore listings in draft mode" do
    xhr :get, :index, {:get_total => 'true', :offset => 0}
    listings = assigns[:listings]
    listings.should include(listings(:bobs_listing_1))
    listings.should_not include(listings(:draft_listing_1))
  end
end

describe ListingsController, " making a new listing (#new)" do
  it "redirects to the wizard" do
    @user = users(:bob)
    log_in(@user)

    new_listing = mock_model(Listing)
    Listing.should_receive(:new).with({:lister => @user, :dealership => @user.dealership}).and_return(new_listing)
    new_listing.should_receive(:save).with(false)
    new_listing.stub!(:vehicle).and_return(nil)

    get :new

    response.should redirect_to(listing_vehicle_url(new_listing))
  end
end

describe ListingsController, " creating a new listing (#create)" do
  before do
    @user = users(:bob)
    log_in(@user)

    @vehicle = vehicles(:jetta_vehicle_1)
    Listing.delete_all

  end

  it "creates a listing" do
    lambda do
      post :create, :listing => {:vehicle => @vehicle}
    end.should change(Listing, :count).by(1)
  end

  it "sets the lister to the currently logged in user" do
    post :create

    @new_listing = Listing.find(:all).last
    @new_listing.lister.should == @user
    @new_listing.lister.dealership.should == @user.dealership
  end

  it "redirects to the 'select vehicle' wizard page if the vehicle isn't set" do
    post :create
    @new_listing = Listing.find(:all).last
    response.should redirect_to(listing_vehicle_path(@new_listing))
  end

  it "redirects to the 'info' wizard page if the is set" do
    post :create, :listing => {:vehicle => @vehicle}
    @new_listing = Listing.find(:all).last
    response.should redirect_to(listing_info_path(@new_listing))
  end

  it "should create a listing in draft mode" do
    post :create
    @new_listing = Listing.find(:all).last
    @new_listing.state.should == :draft
  end

  it "redirects to an existing draft listing" do
    listing = Listing.new(:vehicle => @vehicle, :dealership => @user.dealership)
    listing.save(false)
    @vehicle.reload
    lambda do
      post :create, :listing => {:vehicle => @vehicle}
    end.should_not change(Listing, :count)
    response.should redirect_to(listing_info_path(listing))
  end

end

describe ListingsController, 'with notifications' do

  before :each do
    @alice   = users(:alice)
    @bob     = users(:bob)
    @charlie = users(:charlie)
    @rob     = users(:rob)
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

  it "should mark selling messages for a listing as read when viewing the listing" do
    log_in(users(:bob))
    lambda {
      get :show, :id => listings(:bobs_listing_1), :buyer_id => @charlie.id
    }.should change { users(:bob).listings_with_alerted_notifications.size }.by(-1)
  end
  
  it "should not mark selling messages for a listing as read when the buyer has not been selected" do
    AskEvent.create(:originator => @rob, :prospect => @prospect_1, :comment => "Does it have wheels?")
    log_in(users(:bob))
    lambda {
      get :show, :id => listings(:bobs_listing_1), :buyer_id => @rob.id
    }.should change { users(:bob).listings_with_alerted_notifications.size }.by(0)
  end

end

describe ListingsController, " showing a list of listings for the current user/dealership" do
  it "should return a list of all listings for the current dealership" do
    log_in(users(:bob))
    xhr :get, :index, {:get_total => 'true', :offset => 0}
    listings = assigns[:listings]
  end
end

describe ListingsController, "#complete_sale" do

  it "completes the sale" do
    log_in(users(:bob))
    listing = listings(:bobs_listing_1)
    listing.state.should_not == :completed

    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    offer    = OfferEvent.create(:originator => users(:charlie), :prospect => prospect, :amount => '11.99')

    listing.accept(prospect, :originator => users(:bob))

    get :complete_sale, :id => listing

    listing.reload
    listing.state.should == :completed
    response.should redirect_to(listings_path)
  end

end