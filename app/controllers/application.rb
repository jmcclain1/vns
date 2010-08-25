class ApplicationController < ActionController::Base
  before_filter :require_login
  before_filter :set_navbar_tab
 
  protected
  def set_navbar_tab
    @current_navbar_tab = 'Manage'
  end

  def require_login
    redirect_to new_login_path unless logged_in?
  end

  def tablist_remove(tab_id)
    if tabs = session[:tablist]
      tabs.delete(tab_id.to_i)
      session[:tablist] = tabs
    end
  end

  def set_dealership
    @dealership = logged_in_user.dealership
  end

end
