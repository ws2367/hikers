class RemoveFbFriendsIdsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :fb_friends_ids 
  end

  def down
    add_column :users, :fb_friends_ids, :text
  end
end
