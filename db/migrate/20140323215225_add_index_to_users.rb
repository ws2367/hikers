class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :fb_user_id, :unique => true
  end
end
