dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe PrimaryProfilePhotoController, "#update" do
  controller_name :primary_profile_photo

  it "sets the primary photo for this user" do
    user = users(:valid_user)
    log_in(user)
    profile_photo1 = assets(:basic_1)
    profile_photo2 = assets(:basic_2)
    user.profile.primary_photo.should == profile_photo1
    put :update, :user_id => user.to_param, :id => profile_photo2.to_param
    user.reload
    user.profile.primary_photo.should == profile_photo2 
  end

  it "should allow setting a stock profile photo as the primary photo" do
    user = users(:valid_user)
    log_in(user)
    profile_photo = assets(:basic_1)
    stock_profile_photo = assets(:stock_profile_photo_1)
    user.profile.primary_photo.should == profile_photo
    put :update, :user_id => user.to_param, :id => stock_profile_photo.to_param
    response.should be_success
    user.reload
    user.profile.primary_photo.should == stock_profile_photo
  end

  it "should not allow a user to set another users primary profile photo" do
    user = users(:second_valid_user)
    log_in(user)
    other_user = users(:valid_user)
    
    profile_photo1 = assets(:basic_1)
    profile_photo2 = assets(:basic_2)
    other_user.profile.primary_photo.should == profile_photo1

    proc { put :update, :user_id => other_user.to_param, :id => profile_photo2.to_param }.should raise_error(SecurityTransgression)

    other_user.reload
    other_user.profile.primary_photo.should == profile_photo1
  end

end