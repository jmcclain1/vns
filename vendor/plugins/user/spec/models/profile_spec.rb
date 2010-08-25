require File.dirname(__FILE__) + '/../spec_helper'

describe "A profile" do
  before(:each) do
    @profile = profiles(:for_valid_user)
  end

  it "should be valid" do
    Profile.find(:all).each do |profile|
      profile.should be_valid
    end
  end

  it "should handle years of birth before 1970" do
    @profile.date_of_birth = Date.new(1969, 1, 1)
    @profile.save
    @profile.reload
    @profile.date_of_birth.should == Date.new(1969, 1, 1)
  end

  it "should return a list of profile photos which includes stock photos" do
    photos_including_stock_photos = @profile.photos
    stock_photo = photos_including_stock_photos.detect do |photo|
      photo.is_a? StockProfilePhoto
    end
    stock_photo.should_not be_nil
  end

  it "should return a list of profile photos which excludes stock photos" do
    non_stock_photos = @profile.non_stock_photos
    stock_photo = non_stock_photos.detect do |photo|
      photo.is_a? StockProfilePhoto
    end
    stock_photo.should be_nil
  end

  it "can be edited by owner" do
    @profile.updatable_by?(users(:valid_user)).should == true
  end

  it "returns false when user is not self" do
    @profile.updatable_by?(users(:second_valid_user)).should == false
  end

  it "non-admin others can't update or destroy" do
    users(:second_valid_user).can_update?(profiles(:for_valid_user)).should == false
    users(:second_valid_user).can_destroy?(profiles(:for_valid_user)).should == false
  end

end

describe User, "security: update and destroy" do
  fixtures :users

  it "admin can update and destroy" do
    users(:admin).can_update?(profiles(:for_valid_user)).should == true
    users(:admin).can_destroy?(profiles(:for_valid_user)).should == true
  end

  it "self can update and destroy" do
    users(:valid_user).can_update?(profiles(:for_valid_user)).should == true
    users(:valid_user).can_destroy?(profiles(:for_valid_user)).should == true
  end

  it "non-admin others can't update or destroy" do
    users(:second_valid_user).can_update?(profiles(:for_valid_user)).should == false
    users(:second_valid_user).can_destroy?(profiles(:for_valid_user)).should == false
  end

end