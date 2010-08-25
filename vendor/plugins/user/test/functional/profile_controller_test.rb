require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

class ProfileController
  def rescue_action(e)
    raise e
  end
end

class ProfileControllerTest < UserPluginTestCase

  def setup
    super
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @user = users(:valid_user)
    @profile = profiles(:for_valid_user)
  end

  def test_assumptions
    assert_equal ["1.png", "2.png", "3.png", "8.png"], @profile.photos.collect {|photo| photo.versions[:original].filename}
    assert_equal 4, @profile.photos.length
  end

  def test_edit
    log_in @user
    get :edit, :user_id => @user.to_param  
    assert_response :success
    assert_template 'edit'
  end
  
  def test_update_with_photo
    log_in @user

    original_updated_at = @profile.updated_at
    original_photo_count = @profile.photos.size
    assert_equal ['Virgo Rising', 'Pisces'], @profile.answers_for_question(ProfileQuestion[:sign]).collect(&:to_s)
    assert_equal assets(:basic_1), @profile.primary_photo
    photo = fixture_file_upload('/test.gif', 'image/gif')
    put :update, :user_id => @user.to_param, :profile =>
      {:answers => {:sign => 'Leo'}, :photo => photo, :first_name=>'John', :last_name=>'Smith'}
    assert_redirected_to :action => :show
    
    @profile.reload
    assert_equal 'Leo', @profile.answer_for_question(ProfileQuestion[:sign]).to_s
    assert original_updated_at < @profile.updated_at
    assert_equal original_photo_count + 1, @profile.photos.size
    assert_equal 'John', @profile.first_name
    assert_equal 'Smith', @profile.last_name
  end
  
  def test_update__without_photo
    log_in @user

    original_updated_at = @profile.updated_at
    original_photo_count = @profile.photos.size
    assert_equal ['Virgo Rising', 'Pisces'], @profile.answers_for_question(ProfileQuestion[:sign]).collect(&:to_s)
    assert_equal assets(:basic_1), @profile.primary_photo
    put :update, :user_id => @user.to_param, :profile => {:answers => {:sign => 'Leo'}, :photo => ''}
    assert_redirected_to :action => :show

    @profile.reload
    assert_equal 'Leo', @profile.answer_for_question(ProfileQuestion[:sign]).to_s
    assert original_updated_at < @profile.updated_at
    assert_equal original_photo_count, @profile.photos.size
    assert_equal assets(:basic_1), @profile.primary_photo
  end

  def test_update__cannot_change_someone_elses_profile
    log_in @user
    other_user = users(:second_valid_user)
    begin
      put :update, :user_id => other_user.to_param, :profile => {:answers => {:sign => 'Leo'}, :photo => ''}
      fail
    rescue
    end

  end

  def test_show
    log_in @user
    get :show, :user_id => @user.to_param
    assert_response :success
    assert_template 'show'
    assert_equal @user, assigns(:user)
    assert_equal @profile, assigns(:profile)
  end
end
