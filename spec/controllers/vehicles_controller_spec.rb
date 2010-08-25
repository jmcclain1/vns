require File.dirname(__FILE__) + '/../spec_helper'

#TODO: shouldn't these wizard steps have their own controller specs?
describe VehiclesController, "step 1 => vin" do
  before do
    log_in(users(:bob))
  end

  it "updates the vin and redirects to the style controller" do
    post :create, :vehicle => {:vin => '1FDXF47R18E234567'}, 'wizard[step]' => 'vin'

    response.should redirect_to(vehicle_url(:id => assigns[:vehicle], 'wizard[step]' => 'trim'))
    assigns[:vehicle].vin.should == '1FDXF47R18E234567'
  end

  it "update should show an error message if a bad VIN is entered" do
    post :create, :vehicle => {:vin => 'invalid'}, 'wizard[step]' => 'vin'

    response.should be_success
    response.should render_template('/vehicles/wizard/vin')

    assigns[:vehicle].vin.should == 'invalid'
    flash[:notice].should == "Vin is the wrong length (should be 17 characters)"
  end

  it "update should show an error message if an unknown VIN is entered" do
    post :create, :vehicle => {:vin => '1AAAAA7R18E234567'}, 'wizard[step]' => 'vin'

    response.should be_success
    response.should render_template('/vehicles/wizard/vin')

    assigns[:vehicle].vin.should == '1AAAAA7R18E234567'
    flash[:notice].should == "We could not locate that VIN in our database. Please try again."
  end
end

describe VehiclesController, "step 2 => trim" do
  before do
    log_in(users(:bob))
  end
  
  def create_vehicle
    vehicle = Vehicle.new(:vin => '1FDXF47R18E234567', :cost => 1.00, :actual_cash_value => 2.00, :dealership_id => users(:bob).dealership.id)
    vehicle.save(false)
    return vehicle
  end

  it "should assign all trims found by the vin lookup" do
    vehicle = create_vehicle

    get :show, :id => vehicle, :wizard => {:step => 'trim'}

    response.should be_success
    response.should render_template('/vehicles/wizard/trim')    
    assigns[:vehicle].trims.should == vehicle.trims
  end

  it "updates the model and redirects on successful post" do
    vehicle = create_vehicle

    post :update, :id => vehicle.id,
                  :vehicle => {:trim_id => vehicle.trims.first.id},
                  :wizard => {:step => 'trim'}

    response.should be_redirect
    response.redirected_to.should include('wizard%5Bstep%5D=details')
  end
end

describe VehiclesController, "step 3 => details" do
  before do
    log_in(users(:bob))
  end

  def create_vehicle
    vehicle = Vehicle.new(:vin => '1FDXF47R18E234567', :cost => 1.00, :actual_cash_value => 2.00, :dealership_id => users(:bob).dealership.id)
    vehicle.trim_id = vehicle.trims.first.id
    vehicle.save(false)
    return vehicle
  end

  it "renders the errors if there's a problem" do
    vehicle = create_vehicle

    post :update, :id => vehicle.id,
                  :vehicle => {:stock_number => '123'},
                  :wizard => {:step => 'details'}

    response.should be_success
    response.should render_template('/vehicles/wizard/details')
    flash[:notice].should == ["Odometer is not a number"]
  end

  it "creates all selected evd features and associates them with this vehicle" do
    vehicle = create_vehicle
    features_ids = vehicle.trim.available_features.map {|f| f.id}

    post :update, :id => vehicle.id,
                  :vehicle => {:stock_number => '123', :odometer => '3000'},
                  :evd_features => features_ids,
                  :wizard => {:step => 'details'}

    features_ids.each do |expected_feature|
      vehicle.features.map(&:evd_feature_id).should include(expected_feature)
    end
  end

  it "should redirect to the next step and add the vehicle as a draft" do
    vehicle = create_vehicle

    post :update, :id => vehicle.id,
                  :vehicle => {:stock_number => '123', :odometer => '3000'},
                  :wizard => {:step => 'details'}

    vehicle.reload
    vehicle.dealership.should == users(:bob).dealership
    vehicle.draft.should == true

    response.should redirect_to(vehicle_url(:id => vehicle, 'wizard[step]' => 'add_photos'))    
  end
end

describe VehiclesController, "step 4 => add_photos" do
  before do
    log_in(users(:bob))
  end

  def create_vehicle
    vehicle = Vehicle.new(:vin => '1FDXF47R18E234567', :dealership_id => users(:bob).dealership.id)
    vehicle.trim_id = vehicle.trims.first.id
    vehicle.save(false)
    return vehicle
  end

  it "should redirect to the next step" do
    vehicle = create_vehicle

    post :update, :id => vehicle.id,
                  :vehicle => {},
                  :wizard => {:step => 'add_photos'}

    vehicle = assigns[:vehicle]
    response.should redirect_to(vehicle_url(:id => vehicle, 'wizard[step]' => 'summary'))    
  end
end

describe VehiclesController, "step 5 => summary" do
  before do
    log_in(users(:bob))
  end

  it "should redirect to vehicle details after submit" do
    vehicle = vehicles(:draft_vehicle)

    post :update, :id => vehicle.id,
                  :vehicle => {},
                  :wizard => {:step => 'summary'}

    vehicle = assigns[:vehicle]
    response.should redirect_to(vehicle_path(vehicle))
  end

  it "should add the vehicle to the dealerships inventory after submit" do
    vehicle = vehicles(:draft_vehicle)

    post :update, :id => vehicle.id,
                  :vehicle => {},
                  :wizard => {:step => 'summary'}

    vehicle.reload
    vehicle.dealership.should == users(:bob).dealership
    vehicle.draft.should == false
  end
end

describe VehiclesController do
  before do
    @bob = users(:bob)
    log_in(@bob)
  end

  it "limits the returned list of vehicles based on the current user's dealership" do
    xhr :get, :index
    assigns[:vehicles].should include(vehicles(:jetta_vehicle_1))
    assigns[:vehicles].should include(vehicles(:jetta_vehicle_2))
    assigns[:vehicles].should include(vehicles(:jetta_vehicle_4))
    assigns[:vehicles].should_not include(vehicles(:jetta_vehicle_3))
    assigns[:vehicles].should_not include(vehicles(:draft_vehicle))
  end

  it "can handle ajax update" do
    v = @bob.dealership.all_vehicles.first
    xhr :post, :update,
        :vehicle => {:certified => true, :location => "Lot 31, Space A5"},
        :id => v.id

    response.should be_success
    response.should render_template('vehicles/_edit_details_popup')

    v.reload
    v.location.should == "Lot 31, Space A5"
    v.certified.should == true
  end

  it "can handle ajax update when validation errors are present in the data submitted" do
    v = @bob.dealership.all_vehicles.first
    xhr :post, :update,
        :vehicle => {:odometer => "notANumber", :title_state => "12"},
        :id => v.id

    response.should be_success
    response.should render_template('vehicles/_edit_details_popup')
    flash[:notice].first.should include("number")
    flash[:notice][1].should include("state")
  end

  it "returns vehicles which are not removed from inventory" do
    vehicle_to_be_removed = vehicles(:jetta_vehicle_from_2000)

    xhr :get, :index
    assigns[:vehicles].should include(vehicle_to_be_removed)

    vehicle_to_be_removed.remove_from_inventory

    xhr :get, :index
    assigns[:vehicles].should_not include(vehicle_to_be_removed)
  end
end


