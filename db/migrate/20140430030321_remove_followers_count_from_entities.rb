class RemoveFollowersCountFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :followers_count
  end

  def down
    add_column :entities, :followers_count, :integer
  end
end
