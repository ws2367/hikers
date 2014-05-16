class AddEntityFbUserIdToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :entity_fb_user_id, :integer, :limit => 8
  end
end
