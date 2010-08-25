class UserValidationToken < Token

  after_create :send_validation_email

  def send_validation_email
    EmailMailer.deliver_account_creation_notice(user, self)
  end

  def verify_account!
    return if self.expired?
    user.verify_account!
    if user.save then
      self.used = true
      self.save
    end
  end
end