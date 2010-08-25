require File.dirname(__FILE__) + '/../spec_helper'

include PhotoHelperMethods

describe VehiclePhotosController, "show" do
  before do
    log_in(users(:bob))

    @vehicle = mock_model(Vehicle, {
      :photos => empty_photo_collection,
    })
    @vehicle.stub!(:errors).and_return(ActiveRecord::Errors.new(@vehicle))
    @vehicle.should_receive(:reload).any_number_of_times
    Vehicle.should_receive(:find).with(@vehicle.id).and_return(@vehicle)
  end

  it "should render successfully" do
    get :show, :vehicle_id => @vehicle.id
    response.should be_success
  end
end

describe VehiclePhotosController, "create" do
  it_should_behave_like "TearDownPhotos"

  before do
    log_in(users(:bob))
    @photo = setup_photo("uploaded/vehicle_1.jpg")

    @vehicle = mock_model(Vehicle, {
      :photos => empty_photo_collection,
    })
    @vehicle.stub!(:errors).and_return(ActiveRecord::Errors.new(@vehicle))
    @vehicle.should_receive(:reload).any_number_of_times
    Vehicle.should_receive(:find).with(@vehicle.id).and_return(@vehicle)
  end

  it "should add a photo to the vehicle's photo collection" do
    @vehicle.should_receive(:add_photo).with(@photo)
    post :create, :vehicle_id => @vehicle.id, :photo => @photo
    response.should be_success
  end

  it "should render successfully if no photo is sent" do
    @vehicle.should_not_receive(:add_photo)
    post :create, :vehicle_id => @vehicle.id, :photo => nil
    response.should be_success
  end

  it "should render successfully if a bogus photo is sent" do
    bogus_photo = "xxx"
    @vehicle.stub!(:add_photo).and_raise('Foooooo') 
    post :create, :vehicle_id => @vehicle.id, :photo => bogus_photo
    response.should be_success
  end
end

describe VehiclePhotosController, "set_primary" do
  before do
    log_in(users(:bob))

    @vehicle = mock_model(Vehicle, {
      :photos => empty_photo_collection,
    })
    @vehicle.stub!(:errors).and_return(ActiveRecord::Errors.new(@vehicle))
    @vehicle.should_receive(:reload).any_number_of_times
    Vehicle.should_receive(:find).with(@vehicle.id).and_return(@vehicle)
  end

  it "should make the selected photo primary" do
    photo = mock_model(VehiclePhoto)
    @vehicle.should_receive(:set_primary_photo).once.with(photo.id)
    post :set_primary,
      :vehicle_id => @vehicle.id.to_s,
      :commit => "Submit Text",
      :primary_photo_id => photo.to_param
    response.should render_template('/vehicle_photos/show')
  end
end

describe VehiclePhotosController, "delete" do
  before do
    log_in(users(:bob))

    @photo = mock_model(VehiclePhoto)
    @photos = mock('Photos')
    @photos.should_receive(:delete_if).any_number_of_times.and_return([])

    @vehicle = mock_model(Vehicle, {
      :photos => @photos,
    })
    @vehicle.stub!(:errors).and_return(ActiveRecord::Errors.new(@vehicle))
    Vehicle.should_receive(:find).with(@vehicle.id).and_return(@vehicle)
  end

  it "should delete the selected photo" do
    post :delete,
      :vehicle_id => @vehicle.id.to_s,
      :commit => "Submit Text",
      :photo_id => @photo.to_param
    response.should render_template('/vehicle_photos/show')
  end
end

# Helper methods
def empty_photo_collection
  photos = mock('Photos')
  photos.should_receive(:reload).any_number_of_times
  photos.should_receive(:empty?).any_number_of_times.and_return(true)
  return photos
end
