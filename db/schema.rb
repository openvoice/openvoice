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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100823080841) do

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.string   "im"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_recording"
  end

  create_table "fs_profiles", :force => true do |t|
    t.string   "sip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "incoming_calls", :force => true do |t|
    t.string   "caller_id"
    t.integer  "user_id"
    t.string   "duration"
    t.string   "recording"
    t.string   "transcription"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_id"
    t.string   "call_id"
    t.string   "caller_name"
  end

  create_table "messagings", :force => true do |t|
    t.string   "from"
    t.string   "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "to"
    t.boolean  "outgoing"
    t.string   "from_name"
  end

  create_table "outgoing_calls", :force => true do |t|
    t.integer  "user_id"
    t.string   "callee_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer  "user_id"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "forward"
    t.boolean  "default"
    t.string   "name"
  end

  create_table "profiles", :force => true do |t|
    t.string   "voice"
    t.string   "skype"
    t.string   "sip"
    t.string   "inum"
    t.string   "tropo"
    t.string   "twitter"
    t.string   "gtalk"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "call_url"
    t.string   "voice_token"
    t.string   "messaging_token"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "name"
  end

  create_table "voicemails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "filename"
    t.string   "transcription_id"
  end

end
