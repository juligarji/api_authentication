module ApiAuthentication::Authenticable
    extend ActiveSupport::Concern
    
    included do
       def authenticate_user
            if request.headers[:Authorization].blank?
                return unauthorized
            end

            if ApiAuthentication::User.find_by(:login_token => request.headers[:Authorization]).blank?
                return unauthorized
            end

            decoded_token = JWT.decode request.headers[:Authorization], ApiAuthentication.secret_passphrase.to_s, true, { algorithm: 'HS256' }
            user = ApiAuthentication::User.find_by_auth(decoded_token[0]["auth"])

            if user.blank?
                return unauthorized
            end

            if Time.now >= user.login_token_valid_until 
                return unauthorized
            end
       end

       def current_user
        ApiAuthentication::User.find_by(login_token: request.headers['Authorization']).try(:expose)
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
    end
end