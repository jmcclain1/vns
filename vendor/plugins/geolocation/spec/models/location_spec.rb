require File.dirname(__FILE__) + '/../spec_helper'

describe "A new location" do
  include GeolocationFixtures

  before(:each) do
    @location = Location.new(:address => "My place")
  end

  it "should not be prelocated" do
    @location.should_not be_located
    @location.located_at.should be_nil
    @location.located_by.should be_nil
    @location.latitude.should be_nil
    @location.longitude.should be_nil
  end

  it "should not support distance_from" do
    lambda {@location.distance_from(locations(:papa_toby))}.should raise_error(Location::NotYetLocatedError)
  end
end

describe "A location that has made it through the locating process" do
  include GeolocationFixtures

  before(:each) do
    @location_1 = locations(:ritual_coffee_roasters)
    @location_2 = locations(:papa_toby)
  end

  it "should load from fixtures" do
    @location_1.address.should == "1026 Valencia Street"
  end

  it "should be prelocated" do
    @location_1.should be_located
    @location_1.located_at.should_not be_nil
    @location_1.located_by.should_not be_nil
  end

  it "should find distances from other locations using distance_from" do
    @location_1.distance_from(@location_2).should be_close(0.106211877956722, 0.05)
  end
end

describe "The radians conversion methods" do
  it "should work" do
    location = Location.new(:longitude => -90, :latitude => 45)
    location.longitude_radians.should be_close(-1.5707963267949, 0.001)
    location.latitude_radians.should be_close(0.78539816339745, 0.001)
  end
end

describe "The distance_from method" do
  before(:each) do
    @san_francisco = Location.new(:longitude => -(122+26/60.0), :latitude => (37+46/60.0), :located_by => "Fake")
    @san_jose = Location.new(:longitude => -(121+52/60.0+22/3600.0), :latitude => (37+18/60.0 + 15/3600.0), :located_by => "Fake")
    @new_york = Location.new(:longitude => -(73+58/60.0), :latitude => (40+47/60.0), :located_by => "Fake")
    @north_pole = Location.new(:longitude => 0, :latitude => 90, :located_by => "Fake")
    @reykjavik = Location.new(:longitude => -(21+58/60.0), :latitude => (64+4/60.0), :located_by => "Fake")
    @eighty_degrees_latitude = Location.new(:longitude => 10, :latitude => 80, :located_by => "Fake")
  end

  it "should work for cities" do
    @san_jose.distance_from(@san_francisco).should be_close(44.37, 0.01)
    @new_york.distance_from(@san_francisco).should be_close(2570.46, 0.01)
    @san_francisco.distance_from(@san_francisco).should be_close(0, 0.01)
    @san_francisco.distance_from(@new_york).should be_close(2570.46, 0.01)
  end

  it "should work near north pole" do
    @reykjavik.distance_from(@north_pole).should be_close(1793.79, 0.01)
    @eighty_degrees_latitude.distance_from(@north_pole).should be_close(691.69, 0.01)
  end

  it "should support different units than miles" do
    @san_jose.distance_from(@san_francisco).should be_close(44.37, 0.01)
    @san_jose.distance_from(@san_francisco, :units => :miles).should be_close(44.37, 0.01)
    @san_jose.distance_from(@san_francisco, :units => :kilometers).should be_close(70.40, 0.01)
  end

end