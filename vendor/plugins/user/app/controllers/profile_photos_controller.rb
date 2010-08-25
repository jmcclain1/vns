class ProfilePhotosController < ApplicationController
  include UserResource

  around_filter :secure_using_logged_in_user
  
  def index
    @profile_photos = @user.profile.photos.find(:all)
  end

  def show
    @profile_photo = @user.profile.photos.find(params[:id])
  end

  def create
    @profile_photo = ProfilePhoto.new(:data => params[:profile_photo][:file], :creator => @user)

    if @profile_photo.save and @user.profile.photos << @profile_photo
      flash[:notice] = 'Photo was successfully created.'
      redirect_to profile_photos_url(@profile_photo)
    else
      render :action => "new"
    end
  end

  def destroy
    association = @user.profile.assets_associations.find_by_asset_id(params[:id])
    association.destroy

    respond_to do |format|
      format.html { redirect_to profile_photos_url }
      format.js   {}
    end
  end
end

