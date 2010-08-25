class ApplicationController < ActionController::Base
  include SecureActions

  before_filter :store_location
  before_filter :auto_login
  before_filter :load_logged_in_user
  around_filter :inhibit_retardase

  helper_method :logged_in_user, :logged_in?, :logged_in_as?
  helper :profiles

  protected
  def get_stored_location
    session[:location]  
  end
  
  def store_location
    if should_store_location
      session[:location] = params if request.get?
    end
  end

  def should_store_location
    return false unless request.get? && !request.xhr?
    !self.class.actions_not_storing_location.include?(action_name.to_sym)
  end

  def self.actions_not_storing_location
    @actions_not_storing_location || []
  end

  def self.disable_store_location(*actions)
    @actions_not_storing_location ||= []
    @actions_not_storing_location += actions.collect {|action| action.to_sym}
  end

  def login_as(user)
    self.logged_in_user = user
    user.login!
    login = user.logins.create
    session[:login_id] = login.id
    if params[:auto_login] and not cookies[:auto_login]
      cookies[:auto_login] = {
          :value => AutoLogin.create(:user => @user).token,
          :expires => 6000.days.from_now
      }
    end
  end

  def logout
    cookies.delete(:auto_login)
    self.logged_in_user = nil    
  end

  def auto_login
    if !logged_in? && cookies[:auto_login]
      token = AutoLogin.find_by_token(cookies[:auto_login])
      self.logged_in_user = token.user unless token.nil?
    end
  end

  def load_logged_in_user
    if session.nil? || session[:user_id].nil?
      @logged_in_user = NilUser.instance
    else
      @logged_in_user = User.find(session[:user_id])
    end
  end

  def logged_in_user
    @logged_in_user
  end

  def logged_in_user=(user)
    session[:user_id] = (user ? user.id : nil)
    @logged_in_user = user
  end

  def logged_in?
    !logged_in_user.nil?
  end

  def logged_in_as?(user)
    logged_in? && logged_in_user == user
  end

  def login_required
    unless logged_in?
      redirect_to new_login_url
      return false
    end
    return true
  end
end