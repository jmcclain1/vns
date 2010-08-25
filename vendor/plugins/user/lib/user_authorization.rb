module UserAuthorization
  protected
  def require_logged_in_as_target_user
    render :nothing => true, :status => 403 and return false unless @user.updatable_by?(logged_in_user)
  end

  def require_target_profile_editable_by_logged_in_user
    render :nothing => true, :status => 403 and return false unless @user.profile.updatable_by?(logged_in_user)
  end
end