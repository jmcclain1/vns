require File.dirname(__FILE__) + '/../spec_helper'

describe ShoppingItem do

  it "should have an originator and a dealership" do
    item = ShoppingItem.create

    item.should have(1).error_on(:originator)
    item.should have(1).error_on(:dealership)    
  end

  it "can set dealership based on originator" do
    item = ShoppingItem.create(:originator => users(:charlie))
    item.dealership.should == users(:charlie).dealership
  end

end
