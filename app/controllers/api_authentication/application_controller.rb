module ApiAuthentication
  class ApplicationController < ActionController::API
    include ApiAuthentication::Authenticable
  end
end
