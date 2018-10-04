Rails.application.routes.draw do
  get 'called/test'

  #mount ApiAuthentication::Engine => "/api_authentication"
end
