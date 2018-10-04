ApiAuthentication::Engine.routes.draw do
    # JWT Strategy .............
    get 'jwt/is_authenticated'
    post 'jwt/log_in'
    post 'jwt/sign_up'
    post 'jwt/account_recovery'
    post 'jwt/password_recovery'
    delete 'jwt/log_out'
    # ...........................
end
