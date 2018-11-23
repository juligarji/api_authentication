module ApiAuthentication
    class User < ApplicationRecord
      self.abstract_class = true
      require 'jwt'
  
      # Secure token for password
      has_secure_password
  
      # Secure tokens needed
      has_secure_token :confirmation_token
      has_secure_token :recovery_token
      has_secure_token :confirmation_token
  
      # Before create validations
      before_create :refresh
      before_create :to_lowercase
  
      # Exists validation
      validates :email,:name,:lastname, presence: true, on: [:create, :update]
  
      # Length Validation
      validates :username, length: {in: 6..18}, on: [:create, :update], allow_blank: true
      validates :email, length: {in: 4..50},  on: [:create, :update], allow_blank: true
      validates :name, length: {in: 2..40},  on: [:create, :update], allow_blank: true
      validates :lastname, length: {in: 2..40},  on: [:create, :update], allow_blank: true
      validates :password, length: {in: 6..18}, on: [:create], allow_blank: true
      validates :password_confirmation, length: {in: 6..18}, on: [:create], allow_blank: true
      
      # Confirmation validation
      validates :password, confirmation: true, on: [:create]
  
      # Format validation
      validates :username, format: { with: /\A[a-z0-9\-\_]+\z/i, message: "can only contain letters,numbers and dash" }, allow_blank: true,  on: [:create, :update]
      validates :email, format: {with: /\A[a-z\@\-\_\.]+\z/i, message: "has an invalid format"},allow_blank: true,  on: [:create, :update]
      validates :name,:lastname, format: {with: /\A[a-zàáâçéèêëîïiíôóûùüúÿñæœ\' ]+\z/i, message: "can only contain letters and numbers"},allow_blank: true,  on: [:create, :update]
      
      # Uniqueness
      validates :email,:username,:login_token,:recovery_token,:confirmation_token,on: [:create, :update], uniqueness: true, allow_blank: true
  
      def refresh_login_token
        refresh
        self.save!
      end
  
      def refresh_recovery
        self.regenerate_recovery_token
        self.recovery_token_valid_until = Time.now + 20.minutes
        self.save!
      end
  
      def refresh_confirmation
        self.regenerate_confirmation_token
        self.confirmation_token_valid_until = Time.now + 30.minutes
        self.save!
      end
  
      def expose
        self.slice(:id,:username,:email,:name,:lastname,:last_sign_in_at) 
      end
  
      def self.find_by_auth(auth)
        user = nil
        if auth.try(:match,/[@.]/)  # email
          user = self.find_by(email: auth)
        else # username
          user = self.find_by(username: auth)
        end
        return user
      end
  
      def self.search_by_pattern(pattern)
        users = []
        if pattern.try(:match,/[@.]/)  # email
          users =  self.where("email LIKE ?","%#{pattern}%")
        else # username
          users =  self.where("username LIKE ?","%#{pattern}%")
        end
        return users
      end
  
  
      def validate_recovery_token(token)
        if self.recovery_token_valid_until.blank?
          return false
        end
        if Time.now >= self.recovery_token_valid_until 
          return false
        end
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(token),::Digest::SHA256.hexdigest(self.recovery_token))
      end
  
      def validate_confirmation_token(token)
        if self.confirmation_token_valid_until.blank?
          return false
        end
        if Time.now >= self.confirmation_token_valid_until
          return false
        end
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(token),::Digest::SHA256.hexdigest(self.confirmation_token))
      end
  
      def is_confirmed
        return self.confirmed if ApiAuthentication.confirmable
        return true
      end
  
      private 
        def refresh
          payload = {auth: self.username || self.email, valid_until: Time.now + 15.days }
          self.login_token = JWT.encode payload, ApiAuthentication.secret_passphrase.to_s, 'HS256'
          self.login_token_valid_until = payload[:valid_until]
          self.last_sign_in_at = Time.now
        end
  
        def to_lowercase
          self.email = self.email.try(:downcase).try(:gsub!,/\s+/,'') || self.email.try(:downcase)
          self.username = self.username.try(:downcase).try(:gsub!,/\s+/,'') || self.username.try(:downcase)
          self.name = self.name.try(:downcase).try(:gsub!,/\s+/,' ') || self.name.try(:downcase)
          self.lastname = self.lastname.try(:downcase).try(:gsub!,/\s+/,' ') || self.lastname.try(:downcase)
        end
    end
  end