require File.dirname(__FILE__) + '/../spec_helper'

describe ListingTermsController, "#edit" do

  before do
    log_in(users(:bob))
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def renders_template
    response.should render_template('/listings/wizard/terms')
  end

  it "should show page for this listing" do
    finds_listing
    get :edit, 'listing_id'  => @listing.id.to_param
    response.should be_success
    renders_template
  end
end

describe ListingTermsController, "#update" do

  before do
    log_in(users(:bob))
    @listing = listings(:bobs_listing_1)
  end

  def renders_template
    response.should be_success
    response.should render_template('/listings/wizard/terms')
  end

  it "accepts valid data" do
    listing_params = {'asking_price' => "10.95", 'accept_trade_rules' => '1'}
    post :update, {:listing_id => @listing.to_param, :listing => listing_params}
    response.should redirect_to(listing_recipients_url(@listing))
    @listing.reload
    @listing.asking_price.should == BigDecimal("10.95")
    @listing.accept_trade_rules.should == true
  end

  it "rejects invalid data" do
    listing_params = {'asking_price' => "", 'accept_trade_rules' => ''}
    post :update, {:listing_id => @listing.to_param, :listing => listing_params}
    renders_template
    flash[:notice].should == ["Asking price can't be blank", "Trade rules must be accepted"] 
  end

end

