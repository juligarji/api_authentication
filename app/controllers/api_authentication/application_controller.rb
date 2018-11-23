module ApiAuthentication
  class ApplicationController < ActionController::API
    include ApiAuthentication::Authenticable
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
    
    rescue_from ActiveRecord::RecordInvalid, :with => :record_exeption
    rescue_from ActionController::UnpermittedParameters, ActionController::ParameterMissing, :with => :parameters_exeption
    rescue_from ActionController::RoutingError, :with => :bad_route
    rescue_from NoMethodError,ActionController::UnknownController, :with => :bad_method
    
    private
        def record_exeption(exeption)
          render json:{error: exeption.message }, status: :bad_request
        end
        def parameters_exeption(exeption)
          render json:{error: exeption.message }, status: :unprocessable_entity 
        end
        def bad_route(exeption)
          render json: {error: exeption.message }, status: 0
        end
        def bad_method(exeption)
          render json:{error: exeption.message }, status: :unprocessable_entity
        end
    end
end
