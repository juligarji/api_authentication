require "api_authentication/engine"
require "api_authentication/authenticable"

module ApiAuthentication
  
  # Custom variables needed for the gem
  mattr_accessor :secret_passphrase, :app_root, :recovery_email, :recovery_email_password, :recovery_email_smtp_uri, :recovery_email_smtp_port, :login_days, :account_recovery_callback
 
  def self.setup
    yield self
  end
end
