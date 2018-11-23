require_dependency "api_authentication/application_controller"

module ApiAuthentication
  class JwtController < ApplicationController
    
    before_action :set_login_params,only: [:log_in]
    before_action :set_sign_up_params,only: [:sign_up]
    before_action :set_recovery_account_params, only: [:account_recovery]
    before_action :set_password_recovery_params, only: [:password_recovery]
    before_action :set_update_params, only: [:update]
    before_action :set_search_params, only: [:search]

    before_action :authenticate_all, only: [:log_out,:is_authenticated,:update,:public_data,:send_confirmation,:search]
    
    # Template for allow only certain values of models
    #before_action only: [:is_authenticated] do
    #  authenticate_only('user')
    #end

    def is_authenticated
      render json:{}, status:204
    end

    def log_in
      payload = {}
      user = current_model.find_by_auth(@user_params[:auth])

      if user.blank?
        render json:{error: 'Not Found'}, status: 404
        return
      end

      
      if user.try(:authenticate,@user_params[:password])
   
          user.refresh_login_token

          render json:{token: user.login_token,valid_until: user.login_token_valid_until},status: 200

      else 
        render json: {}, status: 401
      end
    end

    def log_out 
        current_user_model.refresh_login_token

        render json:{}, status: 204
    end

    def update
      current_user_model.update!(@user_params)
      head :no_content
    end

    def public_data
      render json: current_user, status: 200
    end

    def sign_up
        current_model.create!(@user_params)

        render json:{}, status:201
    end

    # Confirmation Logic
    def send_confirmation
      begin

        current_user_model.refresh_confirmation 

        AccountMailer.confirmation(current_user_model,current_user_model.recovery_token, request.base_url).deliver_later
      
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        Rails.logger.info e.message
        render json:{error: "We are having some troubles sending the confirmation email, please try again later"}, status: 500
      end
    end

    def confirmates
      # TODO
      current_user_model = current_model.find_by(:confirmation_token)
    end

    def account_recovery
      if ((not @user_params[:email].blank?) and @user_params[:email].try(:match,/[@.]/) )
        user = current_model.find_by(email: @user_params[:email])

        if user
          begin  
            user.refresh_recovery
    
            AccountMailer.exists(user,user.recovery_token).deliver_later
  
            render json:{}, status:204
          rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
            Rails.logger.info e.message
            puts e.message
            render json:{error: "We are having some troubles sending the email, please try again later"}, status: 500
          end
        else
          begin
            AccountMailer.not_exists(@user_params[:email]).deliver_later
          
          rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
            render json:{error: "We are having some troubles sending the email, please try again later"}, status: 500
          end
        end
      else
        render json:{}, status: 400
      end
    end

    def password_recovery
      if @user_params[:password].length > 18 || @user_params[:password].length < 6
        render json:{}, status: 400
        return
      end

      if @user_params[:password] != @user_params[:password_confirmation]
        render json:{}, status: 400
        return
      end

      user = user.find_by(email: @user_params[:email])
      if user
        if user.validate_recovery_token(@user_params[:token])
     
            user.password = @user_params[:password]
            user.password_confirmation = @user_params[:password_confirmation]
            user.recovery_token_valid_until = Time.now
            ActiveRecord::Base.transaction do
              user.save!
              user.refresh_login_token
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

    def search
      render json: current_model.search_by_pattern(@user_params[:auth]).map{|x| x.expose }, status: 200
    end

    private 
      
      # params definition
      def set_login_params         
          @user_params = params.require('user').permit(:auth,:password)
          @user_params[:auth] = @user_params[:auth].try(:gsub!,/\s+/,'') || @user_params[:auth].try(:downcase)
      end

      def set_sign_up_params
          @user_params = params.require('user').permit(:username,:email,:name,:password,:password_confirmation)
      end

      def set_recovery_account_params
          @user_params = params.require('user').permit(:email)
          @user_params[:email] = @user_params[:email].try(:downcase).try(:gsub!,/\s+/,'') || @user_params[:email].try(:downcase)
      end

      def set_password_recovery_params
          @user_params = params.require('user').permit(:email,:password,:password_confirmation,:token)
          @user_params[:email] = @user_params[:email].try(:downcase).try(:gsub!,/\s+/,'') || @user_params[:email].try(:downcase)
      end
      
      def set_update_params
          @user_params = params.require('user').permit(:username,:name)
      end

      def set_search_params
        @user_params= params.require('user').permit(:auth)
      end
  end
end
