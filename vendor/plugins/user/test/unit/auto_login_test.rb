require File.dirname(__FILE__) + '/../test_helper'

class AutoLoginTest < UserPluginTestCase

  def setup
    super
    @user = users(:valid_user)
  end

end
