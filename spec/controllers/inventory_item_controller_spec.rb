require File.dirname(__FILE__) + '/../spec_helper'

describe InventoryItemsController, "destroy" do
  before do
    log_in(users(:bob))
    @vehicle = vehicles(:jetta_vehicle_2)
  end

  it "removes the association with the dealership but does not delete the vehicle" do
    post :destroy, :id => @vehicle.id.to_s
    @vehicle.reload
    @vehicle.dealership.should == nil
  end

  it "redirects to the dealer inventory page" do
    post :destroy, :id => @vehicle.id.to_s
    response.should redirect_to(vehicles_path)
  end

  it "causes the listing tab to disappear" do
    session[:tablist] = {1 => ['A Tab'], 2 => ['A Tab']}
    post :destroy,
         :id => @vehicle.id.to_s,
         :tab_id => 2

    session[:tablist].keys[1].should == nil
  end
end