require File.dirname(__FILE__) + '/../spec_helper'

describe Image do
  before :all do
    setup_attachment_fu!
  end
  after :all do
    teardown_attachment_fu!
  end

  it "is correctly associated with its file" do
    jetta_image = images(:jetta)
    File.read(jetta_image.public_filename).should_not be_nil
  end

  it "can be associated with a vehicle" do
    jetta = vehicles(:jetta_vehicle_1)
    i = Image.create(:vehicle => jetta)
    i.vehicle.should == jetta
  end

  it "validates uniqueness by vehicle and pivotal (a given vehicle can only have 1 pivotal image)" do
    vehicle = vehicles(:jetta_vehicle_2)
    image_data = read_fixture_attachment(images(:jetta), "image/jpg")

    vehicle.images.create!(:uploaded_data => image_data, :pivotal => true)
    vehicle.images.create!(:uploaded_data => image_data)

    i = vehicle.images[1]
    i.pivotal = true
    i.valid?
    i.should have(1).error_on(:pivotal)
  end
end