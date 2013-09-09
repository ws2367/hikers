class AddFollowersNumToFollows < ActiveRecord::Migration
  def change
    add_column :follows, :followersNum, :integer
  end
end
