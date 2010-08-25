require File.dirname(__FILE__) + '/../spec_helper'

describe ListingRecipientsController, "#edit" do

  before do
    log_in(users(:bob))
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def renders_template
    response.should render_template('/listings/wizard/recipients')
  end

  it "should show page for this listing" do
    finds_listing
    get :edit, 'listing_id'  => @listing.id.to_param
    response.should be_success
    renders_template
  end

  it "shows all users as if they were your partners (for now...)" do
    finds_listing
    get :edit, 'listing_id'  => @listing.id.to_param
    assigns[:partners].should == User.find(:all) - [users(:bob)]
  end

end

describe ListingRecipientsController, "#update" do

  before do
    log_in(users(:bob))
    @listing = listings(:bobs_listing_1)
  end

  def renders_template
    response.should be_success
    response.should render_template('/listings/wizard/terms')
  end

  it "accepts valid data" do
    params = {"user"=>["validalice", "validcathy"], "listing_id" => @listing.to_param}
    post :update, params
    @listing.recipients.should == [users(:alice), users(:cathy)]
    response.should redirect_to(listing_summary_url(@listing))
  end

  it "replaces, not appends, users on the recipient list" do
    @listing.recipients << users(:alice)
    @listing.recipients << users(:bob)

    params = {"user"=>["validalice", "validcathy"], "listing_id" => @listing.to_param}
    post :update, params
    @listing.reload
    @listing.recipients.should == [users(:alice), users(:cathy)]
    response.should redirect_to(listing_summary_url(@listing))
  end

  it "does not break if the user did not select any partners" do
    params = {"listing_id" => @listing.to_param}
    post :update, params

    response.should redirect_to(listing_summary_url(@listing))    
  end

end
