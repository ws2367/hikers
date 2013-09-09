class AddLikersNumToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :likersNum, :integer
  end
end
