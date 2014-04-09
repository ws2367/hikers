class AddFollowersNumToMany < ActiveRecord::Migration
  def change
  	add_column :entities, :followers_count, :integer, :default => 0
    add_column :posts,    :followers_count, :integer, :default => 0
  end
end
