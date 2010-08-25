require File.dirname(__FILE__) + '/../spec_helper'
include PhotoHelperMethods

def create_vehicle
  Vehicle.new(
    :trim_id     => "123",
    :vin          => GOOD_VIN,
    :odometer     => 555666,
    :certified    => true,
    :frame_damage => false,
    :prior_paint  => false,
    :title => false,
    :title_state => "CA",
    :stock_number => 1234,
    :cost => 0.00,
    :actual_cash_value => 0.00
  )
end

describe Vehicle, "its images" do
  before :all do
    setup_attachment_fu!
  end
  after :all do
    teardown_attachment_fu!
  end

  before(:each) do
    @vehicle = create_vehicle
  end

  it "can have one or many features" do
    @vehicle.save!

    feature = Feature.create(:vehicle => @vehicle, :name => "Awesome feature")

    @vehicle.features.should include(feature)
  end

  it "returns days in inventory by calendar day, starting with 1" do
    noon_today = (Time.local(2007, 8, 27, 12, 0, 0)) #2007 Aug 27 12:00
    noon_five_days_ago = noon_today - 5.days
    #
    Time.stub!(:now).and_return(noon_today)
    v = vehicles(:jetta_vehicle_1)

    v.created_at = noon_today
    v.days_in_inventory.should == 1

    v.created_at = noon_five_days_ago
    v.days_in_inventory.should == 6

    v.created_at = (noon_five_days_ago - 1.hour)
    v.days_in_inventory.should == 6

    v.created_at = (noon_five_days_ago + 1.hour)
    v.days_in_inventory.should == 6

    v.created_at = (noon_five_days_ago - 12.hours)
    v.days_in_inventory.should == 6

    v.created_at = (noon_five_days_ago - 13.hours)
    v.days_in_inventory.should == 7

    v.created_at = (noon_five_days_ago + 12.hours)
    v.days_in_inventory.should == 5

    v.created_at = (noon_five_days_ago + 13.hours)
    v.days_in_inventory.should == 5
  end

  it "can have images" do
    image_data = read_fixture_attachment(images(:jetta), "image/jpg")

    @vehicle.save
    @vehicle.images.create!(:uploaded_data => image_data)
    @vehicle.images.create!(:uploaded_data => image_data)

    @vehicle.images.count.should == 2
  end

end

describe Vehicle, "vin validation" do
  before(:each) do
    @vehicle = create_vehicle
  end

  it "succeeds" do
    @vehicle.update_attributes(:vin => GOOD_VIN)
    @vehicle.errors[:vin].should be_nil
  end

  it "fails with less than 17 characters" do
    @vehicle.update_attributes(:vin => "x")
    @vehicle.errors[:vin].should == "Vin is the wrong length (should be 17 characters)"
  end

  it "fails with more than 17 characters" do
    @vehicle.update_attributes(:vin => "12345678901234567X")
    @vehicle.errors[:vin].should == "Vin is the wrong length (should be 17 characters)"
  end

  it "fails with invalid characters" do
    @vehicle.update_attributes(:vin => "123456789 1234567")
    @vehicle.errors[:vin].should == "VIN must contain only letters and numbers"
  end
end

describe Vehicle do
  before(:each) do
    @vehicle = create_vehicle
  end

  it "can return a link to its carfax report" do
    @vehicle.carfax_link.should == "http://www.carfax.com/cfm/ccc_displayhistoryrpt.cfm?partner=VNS_0&vin=#{@vehicle.vin}"
  end

  it "should be valid" do
     @vehicle.should be_valid
  end

  it "should have a list of all 50 states and DC" do
    States::US.all.size.should == 51
    States::US.all.should include(["South Dakota", "SD"])
  end

  it "should strip commas from odometer input" do
    @vehicle.odometer = "345,223.5"
    @vehicle.valid?

    @vehicle.should have(0).error_on(:odometer)
    @vehicle.odometer.should == 345223.5
  end

  it "should be listable if we have title and there is no existing listing" do
    vehicle = vehicles(:jetta_vehicle_4) # has title but no listings in fixtures
    vehicle.listable?.should == true
  end

  it "should not be listable if there is no title" do
    vehicle = vehicles(:jetta_vehicle_2) # does not have title in fixtures
    vehicle.listable?.should == false
  end

  it "should not be listable if there is already a listing" do
    vehicle = vehicles(:jetta_vehicle_1) # already has a listing and title in fixture data
    vehicle.listable?.should == false
  end

  it "can be associated with a dealership initially" do
    @vehicle.save
    new_dealership = dealerships(:valid_dealership_2)
    @vehicle.dealership = new_dealership
    @vehicle.dealership.should == new_dealership
  end

  it "can change which dealership it is associated with" do
    vehicle = vehicles(:jetta_vehicle_1)
    new_dealership = dealerships(:valid_dealership_2)
    vehicle.dealership = new_dealership
    vehicle.dealership.should == new_dealership
  end

  it "looks up its own vin in the trims table" do
    trim1 = mock_model(Evd::Trim)
    trim2 = mock_model(Evd::Trim)
    Evd::Trim.should_receive(:find_all_by_vin).with(GOOD_VIN).and_return([trim1, trim2])
    @vehicle.trims.should == [trim1, trim2]
  end

  it "uses the default trim if there is no trim defined" do
    @vehicle.trim = nil
    trim1 = mock_model(Evd::Trim)
    trim2 = mock_model(Evd::Trim)
    Evd::Trim.should_receive(:find_all_by_vin).with(GOOD_VIN).and_return([trim1, trim2])
    @vehicle.trim.should == trim1
  end
end

describe Vehicle, "pagination and sorting" do
  it "can paginate vehicles in order" do
    bob = users(:bob)
    vehicles = Vehicle.paginate(:user => bob)
    vehicles.size.should == 6
    vehicles[0].id.should == 18006
    vehicles[1].id.should == 18012
    vehicles.last.id.should == 18002

    paginated_vehicles = Vehicle.paginate({:user => bob, :offset => '3', :page_size => '2'})
    paginated_vehicles.size.should == 2
    paginated_vehicles[0].id.should == 18007
    paginated_vehicles[1].id.should == 18001
  end
end

describe Vehicle, "migrated from inventory_items" do

  before :each do
    @vehicle = vehicles(:jetta_vehicle_1)
  end

  it "requires a state if a title exists" do
    @vehicle.title_state = nil
    @vehicle.valid?

    @vehicle.should have(1).error_on(:title_state)
  end

  it "does not require a state if no title exists" do
    @vehicle.title = false
    @vehicle.title_state = nil
    @vehicle.valid?

    @vehicle.should have(0).error_on(:title_state)
  end

  it "only allows valid states" do
    @vehicle.title_state = 'XX'
    @vehicle.valid?

    @vehicle.should have(1).error_on(:title_state)
  end

  it "should strip commas and dollar signs from money fields" do
    @vehicle.actual_cash_value = "$1,234.56"
    @vehicle.cost = "1,234.56"

    @vehicle.valid?
    @vehicle.should have(0).error_on(:actual_cash_value)
    @vehicle.should have(0).error_on(:cost)

    @vehicle.actual_cash_value.should == BigDecimal('1234.56')
    @vehicle.cost.should == BigDecimal('1234.56')
  end

  it "should delete dealership specific attributes when removed from inventory" do
    @vehicle.remove_from_inventory
  
    @vehicle.dealership.should be(nil)
    @vehicle.title.should be(nil)
    @vehicle.stock_number.should be(nil)
    @vehicle.location.should be(nil)
    @vehicle.actual_cash_value.should == 0.00
    @vehicle.cost.should == 0.00
    @vehicle.comments.should be(nil)
    @vehicle.draft.should be(nil)
    @vehicle.should_not be(nil)
  end
end

describe Vehicle, "#add_photo" do
  it_should_behave_like "TearDownPhotos"

  it "makes a VehiclePhoto and adds it" do
    uploaded_file = fixture_file_upload("uploaded/vehicle_1.jpg", "image/jpg")
    photo = VehiclePhoto.new(:data => uploaded_file)
    VehiclePhoto.should_receive(:new_from_upload).with(:data => uploaded_file).and_return(photo)

    vehicle = vehicles(:jetta_vehicle_1)
    capture_photo(vehicle.add_photo(uploaded_file))

    vehicle.photos.should include(photo)
  end
end

describe Vehicle, "#set_primary_photo" do
  it_should_behave_like "TearDownPhotos"
  
  before do
    uploaded_file = fixture_file_upload("uploaded/vehicle_1.jpg", "image/jpg")
    @photo1 = capture_photo(VehiclePhoto.new(:data => uploaded_file))
    @photo2 = capture_photo(VehiclePhoto.new(:data => uploaded_file))
    @vehicle = vehicles(:jetta_vehicle_1)
    @vehicle.photos << @photo1
  end

  it "throws an exception if it's passed a photo that's not in the vehicle's list" do
    lambda do
      @vehicle.set_primary_photo(@photo2.id)
    end.should raise_error(RuntimeError)
  end

  it "makes the given photo the primary photo" do
    @vehicle.photos << @photo2
    @vehicle.primary_photo.should == @photo1
    @vehicle.set_primary_photo(@photo2.id)
    @vehicle.primary_photo.should == @photo2
  end
end

describe Vehicle, "available features" do
  it "can tell if it has an available feature" do
    @vehicle = vehicles(:jetta_vehicle_1)
    available_feature = @vehicle.trim.available_features.first
    @vehicle.add_available_feature(available_feature)
    @vehicle.reload
    @vehicle.has_available_feature?(available_feature).should be_true
    @vehicle.has_available_feature?(@vehicle.trim.available_features.last).should be_false
  end

  it "does not add an available feature twice" do
    @vehicle = vehicles(:jetta_vehicle_1)
    available_feature = @vehicle.trim.available_features.first

    pre_av_features_count = @vehicle.features.size
    @vehicle.add_available_feature(available_feature)
    @vehicle.add_available_feature(available_feature)

    @vehicle.features.size.should == pre_av_features_count + 1
  end
end

describe Vehicle, "#transfer_to" do
  before do
    @vehicle = vehicles(:jetta_vehicle_1)
  end

  it "refuses to transfer to its own dealership" do
    lambda do
      @vehicle.transfer_to(@vehicle.dealership)
    end.should raise_error
  end

  it "transfers a vehicle from one dealership's inventory to another" do
    @vehicle = vehicles(:jetta_vehicle_1)
    selling_dealership = @vehicle.dealership
    buying_dealership = dealerships(:valid_dealership_2)

    @vehicle.days_in_inventory.should_not == 1
    @vehicle.transfer_to(buying_dealership)
    @vehicle.reload
    @vehicle.dealership.should be_nil

#    buying_dealership.reload
    twin = Vehicle.find(:first, :conditions => { :vin => @vehicle.vin, :dealership_id => buying_dealership.id })
#    twin = buying_dealership.vehicles.find_by_vin(@vehicle.vin)
    twin.title?.should be_true
    twin.should_not be_nil
    twin.draft.should == false
    twin.days_in_inventory.should == 1
    twin.dealership.should == buying_dealership
  end
end