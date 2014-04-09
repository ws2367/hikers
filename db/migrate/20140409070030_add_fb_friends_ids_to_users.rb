class AddFbFriendsIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_friends_ids, :text
  end
end
