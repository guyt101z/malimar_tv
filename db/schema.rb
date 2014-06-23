# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140623174100) do

  create_table "active_pages", force: true do |t|
    t.string   "action"
    t.string   "controller"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_activities", force: true do |t|
    t.integer  "admin_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_notifications", force: true do |t|
    t.integer  "admin_id"
    t.string   "type"
    t.string   "message"
    t.datetime "expiry"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "devices", force: true do |t|
    t.integer  "user_id"
    t.string   "serial"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "episodes", force: true do |t|
    t.string   "name"
    t.integer  "episode_number"
    t.string   "url"
    t.integer  "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "login_messages", force: true do |t|
    t.text     "message"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movies", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "genre_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.text     "features"
    t.integer  "price"
    t.integer  "months"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.float    "price"
    t.integer  "days"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", force: true do |t|
    t.string   "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_notifications", force: true do |t|
    t.integer  "sales_rep_id"
    t.string   "type"
    t.string   "message"
    t.datetime "expiry"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_representatives", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.string   "phone"
    t.string   "photo"
    t.string   "company"
    t.float    "account_balance"
    t.float    "commission_rate"
  end

  add_index "sales_representatives", ["email"], name: "index_sales_representatives_on_email", unique: true, using: :btree
  add_index "sales_representatives", ["reset_password_token"], name: "index_sales_representatives_on_reset_password_token", unique: true, using: :btree

  create_table "seasons", force: true do |t|
    t.integer  "series_id"
    t.integer  "season_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "serials", force: true do |t|
    t.integer  "roku_id"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", force: true do |t|
    t.string   "name"
    t.integer  "genre_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "name"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_attachments", force: true do |t|
    t.integer  "support_case_id"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_cases", force: true do |t|
    t.integer  "admin_id"
    t.integer  "user_id"
    t.integer  "sales_representative_id"
    t.text     "issue_description"
    t.integer  "priority"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "title"
  end

  create_table "support_messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: true do |t|
    t.integer  "user_id"
    t.integer  "roku_id"
    t.integer  "sales_rep_id"
    t.text     "product_details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "payment_type"
    t.string   "payment_status"
    t.datetime "customer_paid"
    t.datetime "sales_rep_paid"
  end

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "message"
    t.datetime "expiry"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.string   "phone"
    t.string   "photo"
    t.datetime "last_seen"
    t.text     "note"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
