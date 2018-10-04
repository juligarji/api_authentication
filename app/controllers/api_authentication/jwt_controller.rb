require_dependency "api_authentication/application_controller"

module ApiAuthentication
  class JwtController < ApplicationController

    before_action :set_login_params,only: [:log_in]
    before_action :set_sign_up_params,only: [:sign_up]
    before_action :set_recovery_account_params, only: [:account_recovery]
    before_action :set_password_recovery_params, only: [:password_recovery]
    
    before_action :authenticate_user, only: [:log_out,:is_authenticated]
    
    def is_authenticated
      render json:{}, status:204
    end

    def log_in
      payload = {}
      user = User.find_by_auth(@user_params[:auth])

      if user.try(:authenticate,@user_params[:password])
        begin
          user.refresh_login_token

          render json:{token: user.login_token,valid_until: user.login_token_valid_until},status: 200
        rescue StandardError => e
          render json: {error: e.message}, status: 400
        end
      else 
        render json: {}, status: 401
      end
    end

    def log_out
      user = User.find_by(login_token: request.headers['Authorization'])
      begin
        user.refresh_login_token

        render json:{}, status: 204
      rescue StandardError => e
        render json: {error: e.message}, status: 500
      end
    end

    def sign_up
      begin
        User.create!(@user_params)

        render json:{}, status:201
      rescue StandardError => e  
        render json: {error: e.message}, status: 400
      end
    end

    def account_recovery
      if ((not @user_params[:email].blank?) and @user_params[:email].try(:match,/[@.]/) )
        user = User.find_by(email: @user_params[:email])

        if user
          begin  
            user.refresh_recovery
    
            AccountMailer.exists(user,user.recovery_token).deliver_later
  
            render json:{}, status:204
          rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
            Rails.logger.info e.message
            puts e.message
            render json:{error: "We are having some troubles sending the email, please try again later"}, status: 500
          rescue StandardError => e
            render json:{error: e.message}, status: 400
          end
        else
          begin
            AccountMailer.not_exists(@user_params[:email]).deliver_later
          
          rescue StandardError => e
            render json:{error: "We are having some troubles sending the email, please try again later"}, status: 500
          end
        end
      else
        render json:{}, status: 400
      end
    end

    def password_recovery
      if @user_params[:email].blank? or @user_params[:password_confirmation].blank? or @user_params[:password].blank? or @user_params[:token].blank?
        render json:{}, status: 404
        return
      end

      if @user_params[:password].length > 18
        render json:{}, status: 400
        return
      end

      if @user_params[:password] != @user_params[:password_confirmation]
        render json:{}, status: 400
        return
      end

      user = User.find_by(email: @user_params[:email])
      if user
        if user.validate_recovery_token(@user_params[:token])
          begin
            
            user.password = @user_params[:password]
            user.password_confirmation = @user_params[:password_confirmation]
            user.recovery_token_valid_until = Time.now
            user.save!

          rescue StandardError => e
            render json:{error: e.message}, status: 401
            return
          end
          render json: {}, status: 201
        else
          render json:{}, status: 404
        end
      else
        render json:{}, status: 404
        return
      end
    end
    
    private 

      def set_login_params
        if params.keys.include? 'user'
          params[:user][:auth] = params[:user][:auth].try(:downcase).try(:gsub!,/\s+/,'') || params[:user][:auth].try(:downcase)
          
          @user_params = params.require('user').permit(:auth,:password)
        else
            render json: {}, status: 400
            return false
        end
      end

      def set_sign_up_params
        if params.keys.include? 'user'
          @user_params = params.require('user').permit(:username,:email,:name,:lastname,:password,:password_confirmation)
        else
          render json: {}, status: 404
          return false
        end
      end

      def set_recovery_account_params
        if params.keys.include? 'user'
          params[:user][:email] = params[:user][:email].try(:downcase).try(:gsub!,/\s+/,'') || params[:user][:email].try(:downcase)
          @user_params = params.require('user').permit(:email)
        else
          render json: {}, status: 400
          return false
        end
      end

      def set_password_recovery_params
        if params.keys.include? 'user'
          params[:user][:email] = params[:user][:email].try(:downcase).try(:gsub!,/\s+/,'') || params[:user][:email].try(:downcase)
          @user_params = params.require('user').permit(:email,:password,:password_confirmation,:token)
        else
          render json: {}, status: 400
          return false
        end
      end
  end
end