require File.dirname(__FILE__) + '/../spec_helper'

describe PartnersController do
  before do
    @bob = users(:bob)
    log_in(@bob)

    Partnership.create!(:inviter => @bob, :receiver => users(:charlie))
    Partnership.create!(:inviter => @bob, :receiver => users(:rob))
    Partnership.create!(:inviter => @bob, :receiver => users(:cathy))
  end

  it "can return a list of all the users partners and recognizes sorting and ordering parameters" do
    xhr :get, :index, {:get_total => 'true', :offset => 1}

    assigns[:want_row_count].should == true
    assigns[:total_rows].should == 3
    assigns[:offset].should == '1'
    assigns[:partners].should == [users(:rob), users(:cathy)]
  end

  it "should sort partner by distance" do
    xhr :get, :index, {:get_total => 'true', :s2 => 'ASC'}
    assigns[:partners].should == [users(:rob), users(:charlie), users(:cathy)]

    xhr :get, :index, {:get_total => 'true', :s2 => 'DESC'}
    assigns[:partners].should == [users(:cathy), users(:charlie), users(:rob)]
  end
end