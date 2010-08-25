require File.dirname(__FILE__) + '/../spec_helper'

describe "A location cache" do
  include GeolocationFixtures

  before(:each) do
  end

  it "should lookup locations where it has them in the db" do
    LocationCache.lookup("94102").should be_nil
    location = Location.new(:address => "Foo St")
    LocationCache.cache("94102", location)
    LocationCache.lookup("94102").should == location
    LocationCache.expire("94102")
    LocationCache.lookup("94102").should be_nil
  end
end


