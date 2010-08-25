require File.dirname(__FILE__) + '/../spec_helper'

describe TabsController do
  before do
    log_in(users(:bob))
    session[:tablist] = {}
    session[:location] = {}
    session[:user_id] = 1
  end

  it "can close a tab that exists" do
    session[:location][:controller] = "vehicles"
    t1 = {:id => 1, :name => "Link 1", :href => "/vehicles/1"}
    session[:location][:controller] = "prospects"
    t2 = {:id => 2, :name => "Link 2", :href => "/prospects/2"}
    session[:location][:controller] = "listings"
    t3 = {:id => 3, :name => "Link 3", :href => "/listings/3"}
    session[:tablist]["#{users(:bob).id}_vehicles"] = t1
    session[:tablist]["#{users(:bob).id}_prospects"] = t2
    session[:tablist]["#{users(:bob).id}_listings"] = t3
    
    session[:tablist].values.should include(t1)
    session[:tablist].values.should include(t2)
    session[:tablist].values.should include(t3)
    session[:tablist].size.should == 3

    xhr :post, :destroy, :id => "1_vehicles"
    response.should be_success

    session[:tablist].size.should == 2
    session[:tablist].should_not include(t2)
  end

  it "can handle closing a non-existing tab" do
    t1 = {:id => 1, :name => "Link 1", :href => "/vehicles/1"}
    session[:tablist][1] = t1

    xhr :post, :destroy, :id => 2384792
    response.should be_success

    session[:tablist].size.should == 1
    session[:tablist].values.should include(t1)
  end
end