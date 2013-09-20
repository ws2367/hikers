class AddLikersNumToMany < ActiveRecord::Migration
  def change
    add_column :entities, :likersNum, :integer, :default => 0
    add_column :posts,    :likersNum, :integer, :default => 0
    add_column :comments, :likersNum, :integer, :default => 0
  end
end
