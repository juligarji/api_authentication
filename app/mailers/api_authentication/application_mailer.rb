module ApiAuthentication
  class ApplicationMailer < ActionMailer::Base
    default from: ApiAuthentication.recovery_email_password
    layout 'mailer'
  end
end
