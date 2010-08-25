require File.dirname(__FILE__) + '/../spec_helper'

describe "A Caching locator" do
  include GeolocationFixtures

  before(:each) do
    @base_locator = mock("base_locator")
    @locator = CachingLocator.new(@base_locator)
  end

  it "should lookup in the base locator and cache if not in the cache" do
    location = Location.new(:address => "Foo St")
    LocationCache.lookup("94102").should be_nil
    @base_locator.should_receive(:location_search).with("94102").and_return(location)
    @locator.location_search("94102").should == location
    LocationCache.lookup("94102").should == location
  end

  it "should rely on the cache if already in the cache" do
    location = Location.new(:address => "Foo St")
    LocationCache.cache("94102", location)
    @base_locator.should_receive(:location_search).never
    @locator.location_search("94102").should == location
    LocationCache.lookup("94102").should == location
  end
end


