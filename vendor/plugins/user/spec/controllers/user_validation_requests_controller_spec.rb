dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe UserValidationRequestsController, "#show" do
  controller_name :user_validation_requests
  before(:each) do
    @user = users(:unvalidated_user)
    @token = tokens(:user_validation_token)
  end
end

def should_be_logged_in_as(user)
  assert_logged_in_as(user)
end

def should_not_be_logged_in
  assert_not_logged_in
end

describe UserValidationRequestsController, "#create" do
  controller_name :user_validation_requests

  before(:each) do
    @user = users(:unvalidated_user)
    @user.should_not be_account_validated
    @token = tokens(:user_validation_token)
    @token.should_not be_used
  end

  it "should resend the validation email if the user exists" do
    post :create, :id => @user.to_param

    @user.reload
    @user.should_not be_account_validated
    @token = assigns(:token)
    @token.should_not be_nil
    @token.should_not be_used
    flash[:notice].should =~ /email has been sent/
    response.should redirect_to("login")
  end

  it "should give a sensible error if the user does not exist" do
    post :create, :id => '##nobody##'

    flash[:error].should =~ /there was a problem/
    response.should redirect_to("login")
  end

  it "should work" do
    post :create, :id => @user.to_param
    flash[:notice].should =~ /A new validation email has been sent to unvalidated_user@example.com/
    response.should redirect_to("login")
  end

end

describe UserValidationRequestsController, "#update" do
  controller_name :user_validation_requests

  before(:each) do
    @user = users(:unvalidated_user)
    @user.should_not be_account_validated
    @token = tokens(:user_validation_token)
    @token.should_not be_used
  end

  it "should login and verify the user if the token is valid" do
    put :update, :id => @token.to_param

    @user.reload
    @user.should be_account_validated
    @token.reload
    @token.should be_used
    should_be_logged_in_as(@user)
    flash[:notice].should == "Your account has been verified. Welcome!"
    response.should redirect_to("/")
  end

  it "should redirect to login page if already verified" do
    put :update, :id => @token.to_param
    log_out
    put :update, :id => @token.to_param

    flash[:notice].should =~ /already verified/
    flash[:error].should be_nil
    response.should redirect_to(@controller.send(:login_url))
  end

  it "should only accept the correct token" do
    put :update, :id => "iamnottherighttoken"

    @user.reload
    @user.should_not be_account_validated
    should_not_be_logged_in
    flash[:error].should =~ /problem validating/
    response.should redirect_to(@controller.send(:login_url))
  end
end
