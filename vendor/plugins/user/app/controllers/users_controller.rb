class UsersController < ApplicationController
  before_filter :load_user, :only => [:show, :edit, :update]
  before_filter :login_required, :only => [:edit, :update]
  around_filter :secure_using_logged_in_user

  disable_store_location :new, :create
  require_ssl :new, :create
  filter_parameter_logging( :password )

  def index
    @users = User.find(:all)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Your account has been created.'.customize
    else
      render :action => "new"
    end
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = 'User was successfully updated.'.customize
      redirect_to user_url(@user)
    else
      render :action => "edit"
    end
  end

  def can_edit?
    logged_in_user.can_update?(@user)
  end

  def can_new?
    logged_in_user.can_create?(User.new)
  end

  protected
  def load_user
    # TODO: is this a bug?  Should we be looking up by unique name
    #       or finding by id?
    @user = User.find_by_unique_name(params[:id])
  end
end
