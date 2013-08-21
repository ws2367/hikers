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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130821052000) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "post_id"
    t.integer  "user_id"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contexts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "institution_id"
    t.integer  "user_id"
  end

  add_index "contexts", ["institution_id"], :name => "index_contexts_on_institution_id"
  add_index "contexts", ["user_id"], :name => "index_contexts_on_user_id"

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "followee_id"
    t.string   "followee_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "follows", ["followee_id"], :name => "index_follows_on_followee_id"
  add_index "follows", ["user_id"], :name => "index_follows_on_user_id"

  create_table "hates", :force => true do |t|
    t.integer  "user_id"
    t.integer  "hatee_id"
    t.string   "hatee_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "hates", ["hatee_id"], :name => "index_hates_on_hatee_id"
  add_index "hates", ["user_id"], :name => "index_hates_on_user_id"

  create_table "institutions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  add_index "institutions", ["location_id"], :name => "index_institutions_on_location_id"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "likee_id"
    t.string   "likee_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "likes", ["likee_id"], :name => "index_likes_on_likee_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pictures", :force => true do |t|
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pictures", ["post_id"], :name => "index_pictures_on_post_id"

  create_table "pins", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "user_id"
    t.string   "image_remote_url"
  end

  add_index "pins", ["user_id"], :name => "index_pins_on_user_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "context_id"
    t.integer  "user_id"
  end

  add_index "posts", ["context_id"], :name => "index_posts_on_context_id"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "views", :force => true do |t|
    t.integer  "user_id"
    t.integer  "viewee_id"
    t.string   "viewee_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "views", ["user_id"], :name => "index_views_on_user_id"
  add_index "views", ["viewee_id"], :name => "index_views_on_viewee_id"

end
