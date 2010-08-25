require File.dirname(__FILE__) + '/../spec_helper'

describe ListingVehicleController, "#edit" do

  before do
    log_in(users(:bob))
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def renders_template
    response.should render_template('/listings/wizard/vehicle')
  end

  it "should assign the found listing" do
    finds_listing
    get :edit, 'listing_id'  => @listing.id.to_param
    response.should be_success
    renders_template
    assigns[:listing].should equal(@listing)
  end

  it "also works with a 'listing[id]' parameter" do
    finds_listing
    get :edit, 'listing' => {'id' => @listing.id.to_param }
    response.should be_success
    renders_template
  end

  it "fails if you try to edit a listing from another dealership"
end

describe ListingVehicleController, "with fixtures" do

  it "gives a list of drafts for this dealership" do
    log_in(users(:bob))
    @listing = Listing.new(:dealership => users(:bob).dealership, :lister => users(:bob))
    @listing.save(false)
    get :edit, 'listing' => {'id' => @listing.to_param }
    assigns[:drafts].should == [listings(:draft_listing_1), listings(:nearly_completed_draft_listing)]
  end

end

describe ListingVehicleController, "#update" do

  before do
    log_in(users(:bob))
    @listing = mock_model(Listing)
    @listing.stub!(:errors).and_return(ActiveRecord::Errors.new(@listing))
    finds_listing
    @vehicle = mock_model(Vehicle)
  end

  def finds_listing
    Listing.should_receive(:find).with(@listing.id).and_return(@listing)
  end

  def finds_vehicle_by_vin(vin = GOOD_VIN)
    Vehicle.should_receive(:find_by_vin).with(vin).and_return(@vehicle)
  end

  def finds_vehicle_by_stock_number(stock_number = GOOD_STOCK_NUMBER)
    Vehicle.should_receive(:find_by_stock_number).with(stock_number).and_return(@vehicle)
  end

  def renders_template
    response.should render_template('/listings/wizard/vin')
  end

  def sets_vehicle_and_saves
    @listing.should_receive(:vehicle_id=).with(@vehicle.id)
    @listing.should_receive(:save)
  end

  it "when a valid VIN is passed in, it updates the vehicle id and redirects to the next step" do
    finds_vehicle_by_vin
    sets_vehicle_and_saves
    post :update, 'listing' => {'id' => @listing.id}, 'stock_number' => '', 'vin' => GOOD_VIN
    response.should redirect_to(listing_info_url(@listing))
  end

  it "when a valid Stock # is passed in, it updates the vehicle id and redirects to the next step" do
    finds_vehicle_by_stock_number
    sets_vehicle_and_saves
    post :update, 'listing' => {'id' => @listing.id}, 'vin' => '', 'stock_number' => GOOD_STOCK_NUMBER
    response.should redirect_to(listing_info_url(@listing))
  end

  it "fails when an invalid VIN is passed in" do
    post :update, 'listing' => {'id' => @listing.id}, 'vin' => INVALID_VIN
    flash[:notice].should == "VIN must contain only letters and numbers"
  end

  it "fails when an unknown VIN is passed in" do
    Vehicle.should_receive(:find_by_vin).with(UNKNOWN_VIN).and_return(nil)
    post :update, 'listing' => {'id' => @listing.id}, 'vin' => UNKNOWN_VIN
    flash[:notice].should == "Unknown VIN"
  end

  it "fails when an unknown Stock # is passed in" do
    Vehicle.should_receive(:find_by_stock_number).with(UNKNOWN_STOCK_NUMBER).and_return(nil)
    post :update, 'listing' => {'id' => @listing.id}, 'stock_number' => UNKNOWN_STOCK_NUMBER
    flash[:notice].should == "Unknown stock number"
  end

  it "fails when an blank VIN and blank Stock # are passed in" do
    post :update, 'listing' => {'id' => @listing.id}, 'vin' => '', 'stock_number' => ''
    flash[:notice].should == "Please enter either a VIN or a stock number"
  end

  it "fails when both Stock # and VIN are passed in" do
    post :update, 'listing' => {'id' => @listing.id}, 'vin' => 'xyz', 'stock_number' => '123'
    flash[:notice].should == "Please enter either a VIN or a stock number"
  end

  it "fails when a VIN for a vehicle from another dealership is passed in"
  it "fails when a Stock # for a vehicle from another dealership is passed in"

end
