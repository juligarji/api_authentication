class CreateApiAuthenticationUsers < ActiveRecord::Migration[5.1]
    def change
      create_table :api_authentication_users do |t|
  
         # Data of the new created user
         t.string :username, limit: 18, default:"", unique: true
         t.string :email,limit: 50, null: false, default:"", unique: true
   
         t.string :name, limit: 40, null: false, default: ""
         t.string :lastname, limit: 40, null: false, default: ""
        
         t.string :password, limit:18
         t.string :password_digest
   
         # Confirmation
         t.string :confirmation_token
         t.boolean :confirmed, default: false
         t.datetime :confirmation_sent_at
         t.datetime :confirmed_at
   
         # Login Token
         t.string :login_token, unique: true
         t.datetime :login_token_valid_until
   
         # Recuperation
         t.string :recovery_token, unique: true
         t.datetime :recovery_token_valid_until
   
         # Sign In Date
         t.datetime :last_sign_in_at
  
        t.timestamps
      end
    end
  end