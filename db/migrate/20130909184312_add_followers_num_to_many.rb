class AddFollowersNumToMany < ActiveRecord::Migration
  def change
  	add_column :entities, :followersNum, :integer, :default => 0
    add_column :posts,    :followersNum, :integer, :default => 0
  end
end
