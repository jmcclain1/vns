class PasswordResetToken < Token
  validates_each :expired?, :on => :update do |record, key, value|
    record.errors.add(:expired, "Password change request has expired".customize) if record.expired?
  end
  validates_each :used?, :on => :update do |record, key, used|
    record.errors.add(:used, "Password change request has already been used".customize) if used
  end
  validates_presence_of :user
  validates_associated :user, :message => "Password does not match confirmation".customize

  delegate :password, :to => :user
  delegate :password=, :to => :user
  delegate :password_confirmation=, :to => :user
  delegate :password_confirmation, :to => :user

  before_update :mark_as_used
  before_update :update_user

  after_create :send_password_reset_email

  def mark_as_used
    self.used = true
  end

  def update_user
    user.save
  end

  def send_password_reset_email
    EmailMailer.deliver_password_reset_request(user, self)    
  end
end