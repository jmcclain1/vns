class EmailMailer < ActionMailer::Base
  def password_reset_request(user, token, options = {})
    raise "User needs a valid reset password token" unless token

    about = options[:subject] || "Example: Reset Your Password"
    whom = options[:from] || "'Example Admin' <noreply@example.com>"
    recipients user.email_address
    subject about
    from whom
    multipart("password_reset_request", :user => user, :reset_password_url => reset_password_url(token))
  end

  def account_creation_notice(user, token, options = {})
    about = options[:subject] || "Please validate your account"
    whom = options[:from] || "'Example Admin' <noreply@example.com>"
    recipients user.email_address
    subject about
    from whom
    multipart("account_creation_notice", :user => user, :validation_url => user_validation_url(token))
  end

protected
  def reset_password_url(token)
    url(token, 'password_reset_requests')
  end
  
  def user_validation_url(token)
    url(token, 'user_validation_requests')
  end

  def url(token, controller)
    url_for(
      :controller => controller,
      :action => :update,
      :id => token
    )
  end
end
