require File.dirname(__FILE__) + '/../spec_helper'

describe "A locator" do
  include GeolocationFixtures

  before(:each) do
    @locator = Geolocator.new
  end

  it "should pass search strings through" do
    @locator.should_receive(:location_search).with("mysearchstring")
    @locator.locate("mysearchstring")
  end

  it "should convert locations to search strings" do
    @locator.should_receive(:location_search).with("400 Foo St, Fooville, 12345")
    @locator.locate(Location.new(:address => "400 Foo St", :city => "Fooville", :postal_code => "12345"))
  end

  it "should drop blank fields when coming up with a location search string" do
    @locator.should_receive(:location_search).with("400 Foo St, Fooville, 12345")
    @locator.locate(Location.new(:address => "400 Foo St", :city => "Fooville", :region => "", :postal_code => "12345"))
  end

end

