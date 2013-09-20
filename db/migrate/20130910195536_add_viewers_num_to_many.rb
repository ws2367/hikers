class AddViewersNumToMany < ActiveRecord::Migration
  def change
  	add_column :entities, :viewersNum, :integer, :default => 0
    add_column :posts,    :viewersNum, :integer, :default => 0
  end
end
