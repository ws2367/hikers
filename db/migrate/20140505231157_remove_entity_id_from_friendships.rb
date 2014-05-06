class RemoveEntityIdFromFriendships < ActiveRecord::Migration
  def up
    remove_column :friendships, :entity_id
  end

  def down
    add_column :friendships, :entity_id, :integer
    add_index :friendships, :entity_id
  end
end