class PasswordResetRequestsController < ApplicationController
  require_ssl :show, :update
  filter_parameter_logging( :password )
  disable_store_location :show, :new, :create, :update

  def show
    @token = PasswordResetToken.find_by_token(params[:id])
  end

  def new
    @password_reset_token = PasswordResetToken.new
  end

  def create
    @user = User.find_by_email_address(params[:user][:email_address])
    @token = PasswordResetToken.new(:user => @user)
    if @user.nil?
      flash.now[:error] = 'Unable to locate that email address.'.customize
      render :action => "new"
    elsif (not @user.account_validated?)
      flash.now[:error] = 'This account has not yet been validated. Please check your email.'.customize
      render :template => "error"
    elsif !@token.save
      flash.now[:error] = 'Unable to locate that email address.'.customize
      render :action => "new"
    end
  end

  def update
    @token = PasswordResetToken.find_by_token(params[:id])
    @token.attributes = params[:token]

    if @token.save
      flash[:notice] = 'Your password has been changed; please give it a try.'.customize
      redirect_to post_password_reset_path
    else
      render :action => :show
    end
  end
  
protected
  def post_password_reset_path
    new_login_path
  end
end
