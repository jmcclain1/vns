require File.dirname(__FILE__) + '/../spec_helper'

describe ProfilePhotosController, "#create" do
  controller_name :profile_photos

  it "should create a new photo" do
    user = users(:valid_user)
    photo_count = user.profile.photos.size
    photo = fixture_file_upload('/test.gif', 'image/gif')
    post :create, :user_id => user.to_param, :profile_photo => {:file => photo}
    user.reload
    user.profile.photos.size.should be == photo_count + 1
  end

end

describe ProfilePhotosController, "#delete" do
  controller_name :profile_photos

  it "should delete the selected photo" do
    user = users(:valid_user)
    log_in(user)
    photo = assets(:basic_1)
    photo_count = user.profile.photos.size
    delete :destroy, :user_id => user.to_param, :id => photo.id
    user.reload
    user.profile.photos.size.should be == photo_count - 1
  end

  it "should only delete the profile-to-photo association, not destroy the asset" do
    user = users(:valid_user)
    log_in(user)
    photo = assets(:basic_1)
    photo_count = user.profile.photos.size
    delete :destroy, :user_id => user.to_param, :id => photo.id
    user.reload
    Photo.find_by_id(photo.id).should_not be_nil
  end

  # This test is for http://www.pivotaltracker.com/story/show/126374
  # It doesn't verify or fix http://www.pivotaltracker.com/story/show/126764
  it "should not delete the selected photo if not owned by logged-in user" do

    log_in(users(:second_valid_user))

    photo = users(:valid_user).profile.non_stock_photos.first
    photo_count = users(:valid_user).profile.photos.size

    proc { delete :destroy, :user_id => users(:valid_user).to_param, :id => photo.to_param }.should raise_error(SecurityTransgression)
    response.should_not be_success
    users(:valid_user).reload
    users(:valid_user).profile.photos.size.should == photo_count
  end

  it "should not allow a non-logged-in user to delete photos" do
    user = users(:valid_user)
    photo = user.profile.photos.first
    photo_count = user.profile.photos.size

    proc { delete :destroy, :user_id => user.to_param, :id => photo.to_param }.should raise_error(SecurityTransgression)

    user.reload
    user.profile.photos.size.should be == photo_count
  end

  it "should delete the selected photo via Ajax" do
    user = users(:valid_user)
    log_in(user)
    photo = assets(:basic_1)
    photo_count = user.profile.photos.size
    xhr :delete, :destroy, :user_id => user.to_param, :id => photo.id
    user.reload
    user.profile.photos.size.should be == photo_count - 1
    response.should render_template('destroy')
  end
end
