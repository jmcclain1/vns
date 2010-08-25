require File.dirname(__FILE__) + '/../spec_helper'

describe ShoppingItemsController, "posting " do

  before :each do
    @user = users(:bob)
    log_in(@user)
  end

  it "creates a new entry and redirects back to the GET page" do
    lambda {
      post :create
    }.should change {
      users(:bob).reload
      users(:bob).shopping_items.size
    }.by(1)

    response.should be_redirect
    response.should redirect_to(shopping_items_path)
  end

  it "saves 'any' make as nil" do
    post :create, :item => {:make_id => Evd::Make::ANY}
    item = users(:bob).shopping_items.first
    item.make.should be_nil
    item.model.should be_nil
  end

  it "saves 'any' model as nil" do
    post :create, :item => {:make_id => "FO"}, :FO_model => Evd::Model::ANY
    item = users(:bob).shopping_items.first
    item.make.should_not be_nil
    item.make.should == Evd::Make.find("FO")
    item.model.should be_nil
  end

  it "pulls the model from the correct dropdown list based on make" do
    post :create, :item => {:make_id => "FO"},
      :FO_model => "95", # Ford Crown Victoria
      :CH_model => "2018", # Chevy Malibu Classic
      :VW_model => "1902" # VW Rabbit
    item = users(:bob).shopping_items.first
    item.model.name.should == "Crown Victoria"  
  end

  it "ignores model when make is 'any'" do
    post :create, :item => {:make_id => Evd::Make::ANY},
      :FO_model => "95", # Ford Crown Victoria
      :CH_model => "2018", # Chevy Malibu Classic
      :VW_model => "1902" # VW Rabbit
    item = users(:bob).shopping_items.first
    item.model.should be_nil
  end

end
