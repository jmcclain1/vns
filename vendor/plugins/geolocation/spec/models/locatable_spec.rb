require File.dirname(__FILE__) + '/../spec_helper'

describe "A locatable looking for other locatables" do
  before(:each) do
    Location.destroy_all
    Dog.destroy_all
    Cat.destroy_all
    @cat = create_locatable(Cat, "Steve", -97.74176, 30.266748)
    @houston = create_locatable(Dog, "Houston", -95.362587, 29.76317)
    @amarillo = create_locatable(Dog, "Amarillo", -101.829018, 35.222031)
    @denver = create_locatable(Dog, "Denver", -104.983917, 39.739109)
  end

  it "can find nearby locatables" do
    Dog.find_within_radius(@cat.location, 1).should == []
    Dog.find_within_radius(@cat.location, 250).should == [@houston]
    Dog.find_within_radius(@cat.location, 500).sort.should == [@amarillo, @houston].sort
    Dog.find_within_radius(@cat.location, 1000).sort.should == [@amarillo, @denver, @houston].sort
    Dog.find_within_radius(@amarillo.location, 300).sort.should == [@amarillo, @denver].sort
  end

  it "can accept conditions when finding nearby locatables" do
    Dog.find_within_radius(@cat.location, 1000, :conditions => ["name LIKE ?", "D%"]).should == [@denver]
    Dog.find_within_radius(@cat.location, 1000, :conditions => ["name LIKE 'D%'"]).should == [@denver]
    Dog.find_within_radius(@cat.location, 1000, :conditions => ["name LIKE '%o%'"]).sort.should == [@amarillo, @houston].sort
  end

  it "can accept order and limit clauses as well" do
    Dog.find_within_radius(@cat.location, 1000, :conditions => ["name LIKE '%o%'"], :order => "name DESC").should == [@houston, @amarillo]
    Dog.find_within_radius(@cat.location, 1000, :order => "name ASC", :limit => 2).should == [@amarillo, @denver]
  end

  def create_locatable(klass, name, longitude, latitude)
    location = Location.create(:longitude => longitude, :latitude => latitude, :located_by => "Test")
    obj = klass.create(:name => name, :location => location)
    return obj
  end
end

describe "A new locatable" do
  before(:each) do
    @cat = Cat.create(:name => "foo")
    @locator = mock("locator")
    @cat.locator = @locator
  end

  it "will locate when given appropriate terms" do
    @locator.should_receive(:locate).with("300 Foo St").and_return(Location.new(:address => "300 Foo St", :city => "Fooville"))
    @cat.locate!("300 Foo St")
    @cat.location.address.should == "300 Foo St"
    @cat.location.city.should == "Fooville"
    @cat.save
    @cat.reload
    @cat.location.address.should == "300 Foo St"
    @cat.location.city.should == "Fooville"
  end

  it "will adjust its location when asked" do
    orig_location = Location.new(:address => "400 Foo St")
    @cat.location = orig_location
    @cat.save
    @locator.should_receive(:locate).with(orig_location).and_return(Location.new(:address => "400 Foo St", :city => "Fooville"))
    @cat.locate!
    @cat.reload
    @cat.location.address.should == "400 Foo St"
    @cat.location.city.should == "Fooville"
  end

  it "delegates location-related methods to its location" do
    @cat.location = Location.new(:address => "400 Foo St", :located_by => "Hand")
    @cat.address.should == "400 Foo St"
    @cat.address = "500 Foo St"
    @cat.location.address.should == "500 Foo St"
    @cat.location.should_not be_located
  end
end

describe "A locatable without a location" do
  before(:each) do
    @cat = Cat.create(:name => "foo")
    @locator = mock("locator")
    @cat.locator = nil
  end

  it "will return nil if there is no location to delegate to" do
    @cat.postal_code.should == nil
  end
end