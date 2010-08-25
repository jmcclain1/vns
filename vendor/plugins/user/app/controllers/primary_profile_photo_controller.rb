class PrimaryProfilePhotoController < ApplicationController
  include UserResource
  around_filter :secure_using_logged_in_user

  def update
    @user.profile.primary_photo = ProfilePhoto.find(params[:id])
  end

end
