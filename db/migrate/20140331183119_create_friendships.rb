class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :entity
      t.references :user

      t.timestamps
    end
    add_index :friendships, :entity_id
    add_index :friendships, :user_id
  end
end