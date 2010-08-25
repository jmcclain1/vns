require File.dirname(__FILE__) + '/../test_helper'


class LabeledFormBuilderTest < UserPluginTestCase
  attr_accessor :_erbout
  
  class LabeledFormBuilderController < ApplicationController
    def index
      @user = User.find_by_unique_name(:valid_bob)
      render :inline => ""
    end
  end
  
  def setup
    super
    @controller = LabeledFormBuilderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :index
    @view = @response.template
    self._erbout = ""
  end

  def test_text_area__should_create_label_and_text_area
    actual_html = form_builder_output do |form|
      form.text_area(:email_address)
    end
    
    expected_html = "<p><label for='user_email_address'>Email address</label><br/><textarea rows='20' cols='40' id='user_email_address' name='user[email_address]'></textarea></p>"
    
    assert_dom_equal expected_html, actual_html
  end


  def test_password_field__should_create_label_and_password_field
    html = '<p><label for="user_password">Password</label><br/><input id="user_password" name="user[password]" size="30" type="password" /></p>'
    assert_form_renders(html) {|form|form.password_field(:password)}
  end

  def assert_form_renders(html, &block)
    result =
      @view.form_for :user,
        :url => {:action => :index},
        :builder => LabeledFormBuilder do |form|
          assert_equal(html, yield(form)) if block_given?
        end
  end

  def form_builder_output
    output = ''
    @view.form_for(:user,
                   :url => @controller.send(:users_path),
                   :builder => LabeledFormBuilder) do |form|
      output << yield(form) if block_given?
    end
    return output
  end

end