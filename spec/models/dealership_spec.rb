require File.dirname(__FILE__) + '/../spec_helper'

describe Dealership do

  it "is valid if all required fields exist" do
    dealerships(:valid_dealership_1).valid?.should == true
  end

  it "needs a name" do
    aDealership = Dealership.new

    aDealership.valid?
    aDealership.should have(1).errors_on(:name)
  end

  it "can have a vehicle added to it" do
    dealership = dealerships(:valid_dealership_1)
    vehicle = vehicles(:jetta_vehicle_no_dealership)
    vehicle.update_attribute(:dealership, dealership)
    dealership.draft_vehicles(true).should include(vehicle)
  end

  it "can have draft vehicles associated with it" do
    dealerships(:valid_dealership_1).draft_vehicles.should include(vehicles(:draft_vehicle))
    dealerships(:valid_dealership_1).draft_vehicles.should_not include(vehicles(:jetta_vehicle_1))
  end

  it "can have draft listings associated with it" do
    dealerships(:valid_dealership_1).draft_listings.should include(listings(:draft_listing_1))
    dealerships(:valid_dealership_1).draft_listings.should_not include(listings(:bobs_listing_1))
  end

  it "should not include transient listings in the draft_listings collection" do
    @listing = Listing.new(:dealership => dealerships(:valid_dealership_1))
    @listing.save(false)
    dealerships(:valid_dealership_1).draft_listings.should_not include(@listing)
  end

  it "can have a location" do
    dealerships(:valid_dealership_1).location.should == locations(:big_bobs)  
  end

  it "can have shopping items associated with it" do
    charlie = users(:charlie)
    dealership = charlie.dealership
    item = ShoppingItem.create(:originator => charlie, :min_year => 2000, :max_year => 2000)
    dealership.shopping_items.should == [item]
  end

end
