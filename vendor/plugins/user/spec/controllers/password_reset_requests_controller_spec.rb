dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe PasswordResetRequestsController, "#new" do
  integrate_views

  it "should show the forgot password template" do
    get :new
    response.should render_template("new")
  end
end

describe PasswordResetRequestsController, "#create" do
  before(:each) do
    @user = users(:valid_user)
  end

  it "should not allow unvalidated users to create a password reset request" do
    user = users(:unvalidated_user)
    post :create, :user => {:email_address => user.email_address}
    response.should render_template('error')
    flash.now[:error].should =~ /validated/
  end

  it "should work if given a good email address" do
    post :create, :user => {:email_address => @user.email_address}
    response.should be_success
    response.should render_template("create")
    @user.reload
  end

  it "should render error if given invalid email" do
    post :create, :user => {:email_address => "bad_email_address@example.com"}
    response.should render_template("new")
    flash.now[:error].should =~ /Unable to locate/
  end
end

describe PasswordResetRequestsController, "#show" do
  integrate_views

  it "should work" do
      token = PasswordResetToken.create(:user => users(:valid_user))
      get :show, :id => token.to_param
      response.should be_success
   end
end

describe PasswordResetRequestsController, "#update" do
  integrate_views
  
  before(:each) do
    @user = users(:valid_user)
    @token = PasswordResetToken.create(:user => @user)
    @user.authenticate?("password").should be_true
    log_in(@user)
  end

  it "should update user, changing password, if successful" do
    put :update, :id => @token.to_param, :token => { :password => "newpassword", :password_confirmation => "newpassword" }
    response.should be_redirect
    flash[:notice].should == "Your password has been changed; please give it a try.".customize
    @user.reload.authenticate?("newpassword").should be_true
  end
  
  it "should not update password if fields don't match" do
    put :update, :id => @token.to_param, :token => {
                  :password => 'new password',
                  :password_confirmation => 'and now for something completely different'
                  }
    response.should be_success
    @user.reload.authenticate?("newpassword").should_not be_true
  end
end