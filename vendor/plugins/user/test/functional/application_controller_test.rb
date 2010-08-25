require File.dirname(__FILE__) + '/../test_helper'

class AController < ApplicationController
  before_filter :login_required, :only =>[:requires_login]
  disable_store_location :storage_1, :storage_2

  def requires_login
    render :text => ""
  end

  def storage_1
    render :text => ""
  end

  def storage_2
    render :text => ""
  end

  def storage_3
    render :text => ""
  end

  def index
    super
    render :template => "application/index" 
  end
end

class BController < ApplicationController
  disable_store_location :storage_2
  def storage_1
    render :text => ""
  end

  def storage_2
    render :text => ""
  end
end


class ApplicationControllerTest < UserPluginTestCase

  def setup
    super
    @controller = AController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :index
  end

  def test_logged_in_user__should_use_user_id_in_session
    user = users(:valid_user)
    assert_false @controller.logged_in?

    session[:user_id] = user
    get :index
    assert_equal user, @controller.logged_in_user
  end

  def test_logged_in_user__should_set_user_and_session_user
    user = users(:valid_user)
    @controller.logged_in_user = user
    assert_equal user.id, session[:user_id]
  end

  def test_login_required__when_user_not_logged_in__should_redirect_to_login
    get :requires_login
    assert_response :redirect
  end

  def test_login_required__when_user_authenticated_should_return_true
    user = users(:valid_user)
    log_in(user)
    get :requires_login
    assert_response :success
  end

  def test_auto_login
    user = users(:valid_user)
    the_token = AutoLogin.create(:user => user)
    @request.cookies['auto_login'] = CGI::Cookie.new('auto_login', the_token.token)

    get :index
    assert @response.template.logged_in_as?(user)
  end

  def test_store_location
    get :index
    assert_equal({'action'=>'index', 'controller'=>'a'}, session[:location], "Ordinary actions should store location")
    get :storage_1
    assert_equal({'action'=>'index', 'controller'=>'a'}, session[:location], "Location storage is disabled for storage 1")
    get :storage_2
    assert_equal({'action'=>'index', 'controller'=>'a'}, session[:location], "Same for storage 2")
    get :storage_3
    assert_equal({'action'=>'storage_3', 'controller'=>'a'}, session[:location], "Storage 3 isn't mentioned, so it should store location")
    post :index
    assert_equal({'action'=>'storage_3', 'controller'=>'a'}, session[:location], "Posts should be ignored")
    xhr :get, :index
    assert_equal({'action'=>'storage_3', 'controller'=>'a'}, session[:location], "XHR gets should be ignored")
  end

  def test_store_location__controllers_are_independent
    @controller = BController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :storage_1
    assert_equal({'action'=>'storage_1', 'controller'=>'b'}, session[:location], "Storage 1 should store, even though A disables it, because this is B")
    get :storage_2
    assert_equal({'action'=>'storage_1', 'controller'=>'b'}, session[:location], "B disables storage 2, though.")
  end
end