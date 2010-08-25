dir = File.dirname(__FILE__)
require "#{dir}/../vendor/plugins/pivotal_core_bundle/lib/spec_framework_bootstrap"
require "#{RAILS_ROOT}/spec/spec_constants"
require 'monkey'

class Test::Unit::TestCase
 @@already_loaded_fixtures = {}
end

require File.expand_path(dir + '/../vendor/plugins/user/test/test_case_methods.rb')

Spec::Runner.configure do |config|
  include UserPluginTestCaseMethods
  config.fixture_path = "#{dir}/../test/fixtures/"
  include UserPluginTestCaseMethods

  def read_fixture_attachment(resource, content_type = nil)
    path = resource.full_filename.split("/")[-3..-2].join('/')
    fixture_file_upload("tmp/#{path}/" + resource.filename, content_type)
  end

  def setup_attachment_fu!
    Image.class_eval do
      FileUtils.mkdir_p(RAILS_ROOT + "/test/fixtures/tmp")
      FileUtils.cp_r(RAILS_ROOT + "/test/fixtures/files/.", RAILS_ROOT + "/test/fixtures/tmp")
      has_attachment :content_type => :image,
                     :storage => :file_system,
                     :max_size => 1.megabytes,
                     :thumbnails => { :thumb => '80x80>' },
                     :path_prefix => 'test/fixtures/tmp'
    end    
  end

  def teardown_attachment_fu!
    FileUtils.rm_r(RAILS_ROOT + "/test/fixtures/tmp")
  end
end

def ensure_that_routes_are_loaded
  ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
end
include Spec::Rails::DSL::ControllerBehaviourHelpers::ExampleMethods

module PhotoHelperMethods

  def setup_default_photos
    setup_photo "uploaded/vehicle_1.jpg", "image/jpg"
    setup_photo "uploaded/vehicle_2.jpg", "image/jpg"
    setup_photo "uploaded/RSX.jpg", "image/jpg"
  end

  def setup_photo(path, mimetype = "image/jpg")
    @photos = [] if @photos.nil?

    return capture_photo(VehiclePhoto.new_from_upload(:data => fixture_file_upload(path, mimetype)))
  end

  def capture_photo(photo)
    @photos = [] if @photos.nil?
    @photos << photo

    return photo
  end

  def teardown_photos
    if (@photos)
      @photos.each do |photo|
        photo_id = photo.id

        # If the photo never gets persisted during the test, it won't have an ID.
        if (photo_id)
          photo.destroy
        end
      end
    end
  end

  describe "TearDownPhotos", :shared => true do
    after :each do
      teardown_photos
    end
  end

  describe "SetUpDefaultPhotos", :shared => true do
    it_should_behave_like "TearDownPhotos"

    before :each do
      setup_default_photos
    end
  end

end

module ListingsHelperMethods
  def create_mock_vehicle
    trim = mock('a trim')
    available_features = mock('available_features')
    available_features.stub!(:find).and_return([])
    available_features.stub!(:[]).and_return([])
    trim.stub!(:available_features).and_return(available_features)
    red = mock("Red")
    red.stub!(:id).and_return(1001)
    red.stub!(:name).and_return("red")
    blue = mock("Blue")
    blue.stub!(:id).and_return(10012)
    blue.stub!(:name).and_return("blue")

    mock_model(Vehicle,
      :vin => GOOD_VIN,
      :stock_number => GOOD_STOCK_NUMBER,
      :year => 2005,
      :odometer => 22000,
      :make_name => "Mercedes",
      :model_name => "C Class",
      :trim_name => "C280 Sedan 4D",
      :engine_name => "V6 2.8 Liter",
      :drive_name => "RWD",
      :transmission_name => "Automatic",
      :exterior_color => red,
      :exterior_colors => [red, blue],
      :exterior_color_id => 1001,
      :interior_color => blue,
      :interior_colors => [red, blue],
      :interior_color_id => 10012,
      :trim_id => 19191,
      :trim => trim,
      :features => [],
      :certified => true,
      :title => true,
      :title_state => "California",
      :title_states => States::US.all,
      :frame_damage => true,
      :title => true,
      :prior_paint => false,
      :location => "Lot 49",
      :actual_cash_value => 70.05,
      :cost => 40.49,
      :comments => "Foo",
      :carfax_link => "http://www.google.com"
    )
  end
end
