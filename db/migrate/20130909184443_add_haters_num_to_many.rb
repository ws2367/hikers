class AddHatersNumToMany < ActiveRecord::Migration
  def change
    add_column :entities, :hatersNum, :integer, :default => 0
    add_column :posts,    :hatersNum, :integer, :default => 0
    add_column :comments, :hatersNum, :integer, :default => 0
  end
end
