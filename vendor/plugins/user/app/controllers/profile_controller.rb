class ProfileController < ApplicationController
  include UserResource

  before_filter :login_required, :only => [:edit, :update]

  def show
    @profile = @user.profile

    respond_to do |format|
      format.html { render :action => :show }
      format.xml  { render :xml => @profile.to_xml }
    end
  end

  def edit
    @profile = @user.profile
  end

  def update
    @profile = @user.profile

    respond_to do |format|
      @profile.update_answers!(params[:profile][:answers])
      @profile.update_attribute(:first_name, params[:profile][:first_name])
      @profile.update_attribute(:last_name, params[:profile][:last_name])
      upload = params[:profile][:photo]
      uploaded_photo = add_uploaded_photo_to_profile(upload)
      if @profile.save
        flash[:notice] = 'Profile was successfully updated.'.customize
        format.html { redirect_to profile_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

  protected
  def add_uploaded_photo_to_profile(upload)
    return nil if upload.blank? or upload.is_a? String
    upload.rewind
#TODO: why do we have to rewind the file here?
    photo = ProfilePhoto.create(:original_filename => upload.original_filename,
                                :data => upload,
                                :creator => logged_in_user)
    @profile.photos << photo
    return photo
  end
end
