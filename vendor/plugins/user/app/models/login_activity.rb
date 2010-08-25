class LoginActivity < UserActivity

  def readable_by?(acting_user)
    user == acting_user || user.super_admin?
  end
end