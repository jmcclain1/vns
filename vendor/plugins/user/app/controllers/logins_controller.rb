class LoginsController < ApplicationController
  disable_store_location :new, :create, :destroy
  require_ssl :new, :create
  filter_parameter_logging( :password )
  
  def new
    @user = User.new
  end

  def create
    @request_new_validation = false
    @user = User.authenticate(params[:user])

    respond_to do |format|
      if @user.nil?
        flash.now[:error] = "Login unsuccessful".customize
        @user = User.new(params[:user])
        format.html {render :template => 'logins/new'}
        format.js {render :template => 'logins/create_unsuccessful'}
      elsif @user.needs_to_accept_tos?
        flash.now[:error] = "Please accept terms of service.".customize
        format.html {render :template => 'logins/new_agree_to_tos'}
        format.js {render :template => 'logins/create_agree_to_tos'}
      elsif not @user.account_validated?
        flash.now[:error] = "Your account has not been validated yet. Please check your email.".customize
        @request_new_validation = true
        format.html {render :template => 'logins/new'}
        format.js {render :template => 'logins/create_unvalidated'}
      elsif @user.account_validated?
        login_as(@user)
        flash[:notice] = "Login successful".customize
        format.html {redirect_to post_login_page_url}
        format.js {}
      end     
    end
  end

  def destroy
    @login = Login.find(session[:login_id])
    @login.destroy
    logout
    flash[:notice] = "You have been logged out".customize
    redirect_to post_logout_url
  end

  protected
  def post_login_page_url
    session && session[:location] ? session[:location] : default_post_login_page
  end

  def default_post_login_page
    "/"
  end
  
  def post_logout_url
  "/"
  end
end
