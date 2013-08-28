class RemoveStateFromLikes < ActiveRecord::Migration
  def up
    remove_column :likes, :state
  end

  def down
    add_column :likes, :state, :string
  end
end
