require File.dirname(__FILE__) + '/../spec_helper'

describe ListingInfoController, "#edit" do

  before do
    log_in(users(:bob))
    @vehicle = mock_model(Vehicle)
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
    @listing.stub!(:vehicle).and_return(@vehicle)
    finds_listing
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def renders_template
    response.should render_template('/listings/wizard/info')
  end

  it "should show vehicle details for this listing" do
    get :edit, 'listing_id'  => @listing.id.to_param
    response.should be_success
    renders_template
  end

  it "should set up requirements for display of photo widget" do
    get :edit, 'listing_id' => @listing.id.to_param
    assigns[:vehicle].should_not equal(nil)
  end
end

describe ListingInfoController, "#update" do

  before do
    log_in(users(:bob))
    @vehicle = mock_model(Vehicle)
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
    @listing.stub!(:vehicle).and_return(@vehicle)
    finds_listing
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def renders_template
    response.should render_template('/listings/wizard/terms')
  end

  it "accepts comments" do
    @listing.should_receive(:update_attributes).with({'comments' => "Hello, Chuck!"}).and_return(true)
    @listing.should_receive(:save).with(false).and_return(true)
    post :update, {:listing_id => @listing.to_param, :listing => {'comments' => "Hello, Chuck!"}}
    response.should redirect_to(listing_terms_url(@listing))
  end

end
