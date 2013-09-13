class AddFollowersNumToMany < ActiveRecord::Migration
  def change
  	add_column :entities, :followersNum, :integer
    add_column :posts,    :followersNum, :integer
  end
end
