ApiAuthentication::Engine.routes.draw do
  # JWT Strategy .............
     get 'jwt/is_authenticated'
     get 'jwt/public_data'
     post 'jwt/log_in'
     post 'jwt/sign_up'
     post 'jwt/account_recovery'
     post 'jwt/password_recovery'
     post 'jwt/search'
     put 'jwt/update'
     delete 'jwt/log_out' 
     # ........................... 
end
