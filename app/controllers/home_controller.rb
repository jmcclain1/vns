class HomeController < ApplicationController

  def index
    @user = logged_in_user
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Manage'
  end

end
