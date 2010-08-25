require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  it "can format as a display name" do
    locations(:big_als).display_name.should == "2575 Auto Mall Pkwy, Fairfield CA"
  end
end
