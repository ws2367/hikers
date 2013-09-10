class AddHatersNumToMany < ActiveRecord::Migration
  def change
    add_column :entities, :hatersNum, :integer
    add_column :posts,    :hatersNum, :integer
    add_column :comments, :hatersNum, :integer
  end
end
