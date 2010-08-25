require File.dirname(__FILE__) + '/../spec_helper'

describe ListingSummaryController, "#edit" do

  before do
    log_in(users(:bob))
    @listing = listings(:nearly_completed_draft_listing)

    get :edit, {:listing_id => @listing.to_param}
  end

  it "should show page for this listing" do
    response.should be_success
    response.should render_template('/listings/wizard/summary')
  end

  it "should have a vehicle in the assigns hash" do
    assigns[:vehicle].should_not be(nil)
  end
end

describe ListingSummaryController, "#update" do

  before do
    log_in(users(:bob))
    @listing = listings(:nearly_completed_draft_listing)
  end

  it "marks the listing as not-a-draft" do
    @listing.state.should == :draft
    post :update, {:listing_id => @listing.to_param}
    @listing.reload
    @listing.state.should_not == :draft
  end

  it "creates prospects for each recipient" do
    cathy   = users(:cathy)
    charlie = users(:charlie)
    @listing.recipients << cathy
    @listing.recipients << charlie

    post :update, {:listing_id => @listing.to_param}
    cathy.prospects.first.listing.should   == @listing
    charlie.prospects.first.listing.should == @listing
  end

  it "redirects to the listing details page" do
    post :update, {:listing_id => @listing.to_param}
    response.should redirect_to(listing_url(@listing))
  end

end

