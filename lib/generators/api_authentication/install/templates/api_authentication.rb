ApiAuthentication.setup do |config|
  
  # mdca secure passphrase
  config.secret_passphrase = "my-secret_pass"

  # end point root uri
  config.app_root = "http://my-cool-page"
  
  # address to be sended by email when the user request a password recovery
  config.account_recovery_callback = "http://my-cool-recovery-address"
  
  # Email credentials to send the recovery password message using SMTP authentication
  config.recovery_email = "my_cool_email@email.com"
  config.recovery_email_password = "my-cool-password"
  config.recovery_email_smtp_uri = "smtp.gmail.com"
  config.recovery_email_smtp_port = 587
  
  # login period
  config.login_days = 10 

end