module ApiAuthentication
  class Engine < ::Rails::Engine
    isolate_namespace ApiAuthentication
    config.generators.api_only = true

    initializer "api_authentication", before: :load_config_initializers do |app|
      Rails.application.routes.append do
        mount ApiAuthentication::Engine, at: "/api_authentication"
      end
    end

    initializer "api_authentication", after: :load_config_initializers do |app|
      # Email configuration ..........................................
      config.action_mailer.smtp_settings = {
        address: ApiAuthentication.recovery_email_smtp_uri,
        port: ApiAuthentication.recovery_email_smtp_port,
        authentication: "plain",
        enable_starttls_auto:true,
        user_name: ApiAuthentication.recovery_email,
        password: ApiAuthentication.recovery_email_password
      }
      config.action_mailer.raise_delivery_errors = false
      config.action_mailer.perform_caching = false
      config.action_mailer.raise_delivery_errors = true
      config.action_mailer.delivery_method = :smtp
    end
  end
end
