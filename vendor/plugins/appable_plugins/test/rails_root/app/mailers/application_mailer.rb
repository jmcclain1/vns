class ApplicationMailer < ActionMailer::Base
  def self.in_application_mailer?
    true
  end
end