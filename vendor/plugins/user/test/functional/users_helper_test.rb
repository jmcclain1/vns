require File.dirname(__FILE__) + '/../test_helper'

class UsersHelperController < ApplicationController
  helper :users
end

class UsersHelperTest < UserPluginTestCase

  def setup
    super
    @controller = UsersHelperController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    get :index
    @view = @response.template
  end

  def test_display_attr
    foo = flexmock("foo")
    foo.should_receive(:bar).and_return("baz")
    @view.instance_variable_set("@foo", foo)
    text = @view.display_attr("foo", "bar")
    assert_equal "<p><label for=\"foo_bar\">Bar</label><br/><span id=\"foo_bar\">baz</span></p>", text
  end

end
