dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe LoginsController, "#new" do
  controller_name :logins

  it "should show the login page" do
    get :new
    response.should be_success
    response.should render_template("new")
  end
end

describe LoginsController, "#create" do
  controller_name :logins

  it "should log the user on if their credentials are correct and redirect back" do
    request.session[:location] = "/"
    user = users(:valid_user)
    post :create, 
         :user => {:email_address => user.email_address, 
                   :password => 'password'}
    should_be_logged_in_as(user)
    response.should redirect_to("/")
    flash[:notice].should == "Login successful"
  end

  it "should log the user on with their unique_name" do
    request.session[:location] = "/"
    user = users(:valid_user)
    post :create,
         :user => {:email_address => user.unique_name, 
                   :password => 'password'}
    should_be_logged_in_as(user)
    response.should redirect_to("/")
    flash[:notice].should == "Login successful"
  end

  it ",for an AJAX request, should log the user on if their credentials are correct and render rjs update" do
    user = users(:valid_user)
    xhr :post, :create,
        :user => {:email_address => user.email_address,
                  :password => 'password'}
    should_be_logged_in_as(user)
    response.should render_template('create')
  end

  it ",for an AJAX request, should fail if their credentials are incorrect" do
    user = users(:valid_user)
    xhr :post,
        :create,
        :user => {:email_address => user.email_address,
                  :password => 'wrong_password'}
    should_not_be_logged_in
    response.should render_template('create_unsuccessful')
  end

  it ",for an AJAX request, should fail if not validated" do
    user = users(:unvalidated_user)
    xhr :post,
        :create,
        :user => {:email_address => user.email_address,
                  :password => 'password'}
    should_not_be_logged_in
    response.should render_template('create_unvalidated')
  end

  it "should fail if not validated" do
    user = users(:unvalidated_user)
    post :create, 
         :user => {:email_address => user.email_address,
                   :password => 'password'}
    response.should render_template("logins/new")
    should_not_be_logged_in
    flash.now[:error].should =~ /not been validated/
  end

  it "should fail if given a bad password" do
    user = users(:valid_user)
    post :create, 
         :user => {:email_address => user.email_address,
                   :password => 'bad password'}
    response.should render_template("logins/new")
    flash.now[:error].should == "Login unsuccessful".customize
    should_not_be_logged_in
  end

  it "should store auto login cookie if asked" do
    user = users(:valid_user)
    post :create,
         :user => {:email_address => user.email_address,
                   :password => 'password'},
         :auto_login => true
    cookies['auto_login'].size.should be > 0
  end

  it 'should require tos accepted if user has not accepted latest tos' do
    user = users(:user_with_old_tos)
    user.needs_to_accept_tos?.should == true
    post :create,
         :user => {:email_address => user.email_address,
                   :password => 'password'}
    should_not_be_logged_in
    flash.now[:error].should == "Please accept terms of service."
    response.should render_template("logins/new_agree_to_tos")
  end

end

def should_be_logged_in_as(user)
  assert_logged_in_as(user)
end
def should_not_be_logged_in
  assert_not_logged_in
end

describe LoginsController, "#destroy" do
  controller_name :logins
  before(:each) do
    @user = users(:valid_user)
    log_in(@user)
    should_be_logged_in_as(@user)
  end

  it "should clear session when post" do
    delete :destroy
    response.should redirect_to("/")
    should_not_be_logged_in
    flash[:notice].should == "You have been logged out"
  end

  it "should clear auto_login cookies" do
    user = users(:valid_user)
    delete :destroy
    cookies['auto_login'].size.should == 0
    post :create,
         :user => {:email_address => user.email_address,
         :password => 'password'
         },
         :auto_login => true
    cookies['auto_login'].size.should be > 0
    delete :destroy
    cookies['auto_login'].size.should == 0
  end
end

describe "SSL redirects" do
  controller_name :logins
  it "works when use_ssl is on" do
    SecureActions.redefine_const(:USE_SSL, true)
    get :new
    # TODO: This line failed when we made rspec on rails throw controller exceptions.
    # Is it needed???
    #get @controller.send(:new_login_url)
    @controller.send(:new_login_url).should =~ /https/
#TODO: Figure out why this doesn't resolve bi-directionally
#    get :new
#    response.should redirect_to("https://test.host/login")
  end

  after(:each) do
    SecureActions.redefine_const(:USE_SSL, false)
  end
end
