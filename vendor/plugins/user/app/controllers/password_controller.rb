class PasswordController < ApplicationController
  include UserResource

  disable_store_location :edit, :update
  require_ssl :edit, :update
  filter_parameter_logging( :password )
  before_filter :login_required, :only => [:edit, :update]

  def edit
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = 'Password was successfully updated.'.customize
      redirect_to profile_url(@user)
    else
      render :action => "edit"
    end
  end
end
