module ApiAuthentication
  class AccountMailer < ApplicationMailer

    def exists(user,token)
      @user = user
      @token = token
      mail(to: user.email,subject: 'Account Recovery')
    end

    def not_exists(email)
      mail(to: email,subject: 'Account Recovery')
    end
  end
end
