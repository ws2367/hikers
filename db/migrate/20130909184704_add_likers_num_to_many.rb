class AddLikersNumToMany < ActiveRecord::Migration
  def change
    add_column :entities, :likersNum, :integer
    add_column :posts,    :likersNum, :integer
    add_column :comments, :likersNum, :integer
  end
end
