class UserValidationRequestsController < ApplicationController
  def show
    @token = UserValidationToken.find_by_token(params[:id])
  end

  def create
    @user = User.find_by_unique_name(params[:id])
    respond_to do |format|
      if @user.nil?
        flash[:error] = "Sorry, there was a problem validating your account. Make sure the email address you entered matches your confirmation email.".customize
        format.html {redirect_to new_login_url}
        format.js {}
      else
        @token = UserValidationToken.create(:user => @user)
        format.html {
          flash[:notice] = "A new validation email has been sent to #{@user.email_address}"
          redirect_to new_login_url
        }
        format.js {}
      end
    end
  end

  def update
    @token = UserValidationToken.find_by_token(params[:id])
    @user = @token.user unless @token.nil?
    if @token.nil?
      flash[:error] = "Sorry, there was a problem validating your account. Make sure the URL you entered matches your confirmation email.".customize
      redirect_to login_url
    elsif @token.expired?
      flash[:error] = 'User verification request has expired.'.customize
      redirect_to new_password_reset_token_url
    elsif @user.account_validated?
      flash[:notice] = "You've already verified this account. Please log in.".customize
      redirect_to login_url
    else
      @token.verify_account!
      login_as(@user)
      flash[:notice] = "Your account has been verified. Welcome!".customize
      redirect_to default_post_verification_url
    end
  end
  
  protected
  def default_post_verification_url
    "/"
  end
end

