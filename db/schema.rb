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

ActiveRecord::Schema.define(version: 20140804122802) do

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
    t.string   "message"
    t.datetime "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "viewed"
    t.string   "notif_type"
    t.string   "link"
  end

  create_table "admin_permissions", force: true do |t|
    t.string   "permission"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_roles", force: true do |t|
    t.string   "name"
    t.boolean  "create_user"
    t.boolean  "manage_user"
    t.boolean  "create_rep"
    t.boolean  "manage_rep"
    t.boolean  "accept_cancel_payment"
    t.boolean  "authorize_withdrawal"
    t.boolean  "update_plan_invoice"
    t.boolean  "update_videos"
    t.boolean  "update_mail_settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manage_support_tickets"
    t.boolean  "create_admin"
    t.boolean  "manage_admin"
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
    t.integer  "role_id"
    t.datetime "last_seen"
    t.string   "timezone"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "background_tasks", force: true do |t|
    t.string   "name"
    t.datetime "last_performed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "error"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "genre"
    t.string   "content_type"
    t.string   "content_quality"
    t.string   "item_type"
    t.integer  "rank"
    t.boolean  "free"
    t.boolean  "front_page"
  end

  create_table "channels", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "free"
    t.boolean  "roku"
    t.boolean  "ios"
    t.boolean  "android"
    t.boolean  "web"
    t.string   "image"
    t.string   "stream_url"
    t.text     "genres"
    t.text     "actors"
    t.string   "content_type"
    t.string   "content_quality"
    t.string   "bitrate"
    t.text     "synopsis"
    t.string   "stream_name"
    t.string   "rtmp_url"
    t.boolean  "front_page"
    t.string   "banner"
  end

  create_table "daily_data", force: true do |t|
    t.date     "date"
    t.integer  "new_sign_ups",                       default: 0
    t.integer  "renewals",                           default: 0
    t.datetime "user_updated"
    t.float    "commission_earned",                  default: 0.0
    t.float    "commission_confirmed",               default: 0.0
    t.integer  "withdrawal_requests_created",        default: 0
    t.float    "withdrawal_requests_created_value",  default: 0.0
    t.integer  "withdrawal_requests_approved",       default: 0
    t.float    "withdrawal_requests_approved_value", default: 0.0
    t.integer  "withdrawal_requests_denied",         default: 0
    t.float    "withdrawal_requests_denied_value",   default: 0.0
    t.datetime "rep_updated"
    t.integer  "transactions_completed",             default: 0
    t.float    "transactions_completed_value",       default: 0.0
    t.integer  "transactions_paid",                  default: 0
    t.float    "transactions_paid_value",            default: 0.0
    t.datetime "tx_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "wd_updated"
  end

  create_table "devices", force: true do |t|
    t.integer  "user_id"
    t.string   "serial"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.date     "expiry"
  end

  create_table "episodes", force: true do |t|
    t.string   "video_id"
    t.string   "title"
    t.integer  "episode_number"
    t.date     "release_date"
    t.string   "stream_url"
    t.string   "synopsis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length"
    t.integer  "show_id"
    t.string   "rtmp_url"
  end

  create_table "genres", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "invoice_logos", force: true do |t|
    t.string   "image"
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

  create_table "mail_templates", force: true do |t|
    t.string   "name"
    t.text     "body"
    t.text     "css"
    t.text     "required_variables"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
  end

  create_table "movies", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.boolean  "roku"
    t.boolean  "ios"
    t.boolean  "android"
    t.boolean  "web"
    t.string   "stream_url"
    t.text     "genres"
    t.text     "actors"
    t.boolean  "free"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_quality"
    t.string   "bitrate"
    t.text     "synopsis"
    t.string   "stream_name"
    t.string   "rtmp_url"
    t.date     "release_date"
    t.integer  "length"
    t.boolean  "front_page"
    t.string   "banner"
  end

  create_table "note_files", force: true do |t|
    t.integer  "note_id"
    t.string   "file"
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

  create_table "rep_notifications", force: true do |t|
    t.integer  "sales_rep_id"
    t.string   "message"
    t.string   "notif_type"
    t.date     "expires"
    t.boolean  "viewed"
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
    t.string   "paypal"
    t.string   "timezone"
  end

  add_index "sales_representatives", ["email"], name: "index_sales_representatives_on_email", unique: true, using: :btree
  add_index "sales_representatives", ["reset_password_token"], name: "index_sales_representatives_on_reset_password_token", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "name"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shows", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "roku"
    t.boolean  "web"
    t.boolean  "ios"
    t.boolean  "android"
    t.boolean  "free"
    t.text     "actors"
    t.text     "genres"
    t.string   "bitrate"
    t.string   "content_quality"
    t.string   "content_type"
    t.text     "synopsis"
    t.boolean  "front_page"
    t.string   "banner"
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
    t.integer  "transaction_id"
  end

  create_table "support_messages", force: true do |t|
    t.integer  "user_id"
    t.integer  "admin_id"
    t.integer  "sales_representative_id"
    t.integer  "support_case_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_logs", force: true do |t|
    t.string   "message"
    t.boolean  "error"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
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
    t.datetime "customer_refunded"
    t.float    "balance_used"
    t.string   "paypal_id"
  end

  create_table "user_notes", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "note"
    t.string   "note_colour"
    t.text     "checklist",   limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "message"
    t.datetime "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "viewed"
    t.string   "notif_type"
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
    t.date     "expiry"
    t.string   "timezone"
    t.string   "refer_code"
    t.float    "balance"
    t.boolean  "mailchimp"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "withdrawals", force: true do |t|
    t.integer  "sales_rep_id"
    t.float    "amount"
    t.string   "status"
    t.integer  "admin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved"
    t.text     "note"
  end

end
