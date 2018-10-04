# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180928001817) do

  create_table "api_authentication_users", force: :cascade do |t|
    t.string "username", limit: 20, default: ""
    t.string "email", limit: 50, default: "", null: false
    t.string "name", limit: 50, default: "", null: false
    t.string "lastname", limit: 50, default: "", null: false
    t.string "password", limit: 18
    t.string "password_digest"
    t.string "confirmation_token"
    t.boolean "confirmed", default: false
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.string "login_token"
    t.datetime "login_token_valid_until"
    t.string "recovery_token"
    t.datetime "recovery_token_valid_until"
    t.datetime "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
