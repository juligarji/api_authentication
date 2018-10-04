module ApiAuthentication::Concerns::Authenticable
    extend ActiveSupport::Concern
    included do
       def current_user
        render json: {headers: request.headers.as_json}
        render json: {value: "autehcicable"}
        return false
       end
    end
end