module ApiAuthentication::Authenticable
    extend ActiveSupport::Concern

    included do
       before_action :set_global_model, exept: [:authenticate_only]
       rescue_from NoMethodError, :with => :model_not_set
       
       def authenticate_all
            if request.headers[:Authorization].blank?
                return unauthorized
            end

            if @MODEL.find_by(:login_token => request.headers[:Authorization]).blank?
                return unauthorized
            end
           
            decoded_token = JWT.decode request.headers[:Authorization], ApiAuthentication.secret_passphrase.to_s, true, { algorithm: 'HS256' }
            user = @MODEL.find_by_auth(decoded_token[0]["auth"])

            if user.blank?
                return not_found
            end

            if Time.now >= user.login_token_valid_until 
                return unauthorized
            end
            @USER = user.expose
            @USER_MODEL = user
       end

       def authenticate_only(model_name)
            begin
                if request.headers['Account-Type'].downcase.classify != model_name.classify
                    raise NameError
                end

                @MODEL = model_name.downcase.classify.constantize
                
                authenticate_all
                rescue NameError,NoMethodError => e
                    render json:{error: 'You have to include a valid account type'}, status: :unprocessable_entity
                return false
            end
        end

       def current_user
            return @USER unless @USER.blank?
        
            @USER = @MODEL.find_by(login_token: request.headers['Authorization']).try(:expose)
            return @USER
       end 

       def current_user_model
            return @USER_MODEL unless @USER_MODEL.blank?
            @USER_MODEL = @MODEL.find_by(login_token: request.headers['Authorization'])
            return @USER_MODEL
        end 

       def current_model
        return @MODEL unless @MODEL.blank?

        begin
            @MODEL = request.headers['Authorization'].capitalize.constantize
            return @MODEL
        rescue NameError,NoMethodError => e
            render json:{error: 'You have to include the account type'}, status: :unprocessable_entity
        end
       end
      
        def user_confirmed
            render json: {error: 'Unconfirmed'}, status: :forbidden unless current_user_model.is_confirmed
            return false
        end

       private
            def unauthorized
                    head :unauthorized
                    return false
            end
            def not_found
                head :not_found
                return false
            end

            def unconfirmed
                render json: {error: 'Unconfirmed'}, status: :forbidden
                return false
            end

            def model_not_set
                render json:{error: 'Model has not been set'}, status: :unprocessable_entity
            end

            def set_global_model
                return @MODEL unless @MODEL.blank?
                begin
                  @MODEL = request.headers['Account-Type'].downcase.classify.constantize
               
                 rescue NameError,NoMethodError => e
                  render json:{error: 'You have to include a valid account type'}, status: :unprocessable_entity
                  return false
                end
            end
    end
end