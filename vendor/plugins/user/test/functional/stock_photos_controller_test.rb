require File.dirname(__FILE__) + '/../test_helper'
require 'stock_photos_controller'

# Re-raise errors caught by the controller.
class StockPhotosController
  def rescue_action(e)
    raise e
  end

  def active?
    true
  end
end

class StockPhotosControllerTest < UserPluginTestCase

  def setup
    super
    @controller = StockPhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = assets(:stock_photo_1).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:photo)
    assert assigns(:photo).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:photo)
  end

  def test_create
    photo = fixture_file_upload('/../fixtures/test.gif', 'image/gif')
    num_photos = GenericStockPhoto.count

    post :create, :stock_photo => {:data => photo}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_photos + 1, GenericStockPhoto.count
  end

  def test_create__when_none_already_exist
    GenericStockPhoto.find(:all).each do |photo|
      post :destroy, :id => photo.id
    end

    assert_equal 0, GenericStockPhoto.count

    photo = fixture_file_upload('/../fixtures/test.gif', 'image/gif')
    post :create, :stock_photo => {:data => photo}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal 1, GenericStockPhoto.count
  end

  def test_create__other_stock_type
    photo = fixture_file_upload('/../fixtures/test.gif', 'image/gif')
    num_photos = GenericStockPhoto.count

    post :create, :stock_type => 'GenericStockPhoto', :stock_photo => {:data => photo}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_photos + 1,  GenericStockPhoto.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:photo)
    assert assigns(:photo).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy__generic_stock_photo
    assert_nothing_raised {
      GenericStockPhoto.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      GenericStockPhoto.find(@first_id)
    }
  end

  def test_destroy__stock_profile_photo
    stock_profile_photo_id = assets(:stock_profile_photo_1).id
    assert_nothing_raised {
      StockProfilePhoto.find(stock_profile_photo_id)
    }

    post :destroy, :id => stock_profile_photo_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      GenericStockPhoto.find(stock_profile_photo_id)
    }
  end
end
