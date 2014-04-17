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

ActiveRecord::Schema.define(:version => 20140417094310) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "post_id"
    t.integer  "user_id"
    t.boolean  "deleted",    :default => false
    t.string   "uuid"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "connections", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "connections", ["entity_id"], :name => "index_connections_on_entity_id"
  add_index "connections", ["post_id"], :name => "index_connections_on_post_id"

  create_table "entities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "user_id"
    t.integer  "followers_count",              :default => 0
    t.integer  "fb_user_id",      :limit => 8
    t.string   "institution"
    t.string   "location"
  end

  add_index "entities", ["user_id"], :name => "index_contexts_on_user_id"

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "followee_id"
    t.string   "followee_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "follows", ["followee_id"], :name => "index_follows_on_followee_id"
  add_index "follows", ["user_id"], :name => "index_follows_on_user_id"

  create_table "friendships", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friendships", ["entity_id"], :name => "index_friendships_on_entity_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "user_id"
    t.integer  "followers_count", :default => 0
    t.boolean  "deleted",         :default => false
    t.string   "uuid"
    t.float    "popularity",      :default => 0.0
    t.integer  "comments_count",  :default => 0
    t.boolean  "is_active",       :default => false
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "reports", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shares", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sharee_id"
    t.string   "sharee_type"
    t.text     "numbers"
    t.datetime "sent_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "sign_in_count",                     :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "fb_user_id",           :limit => 8
    t.string   "fb_access_token"
    t.text     "fb_friends_ids"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id", :unique => true

end
