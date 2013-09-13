class AddViewersNumToMany < ActiveRecord::Migration
  def change
  	add_column :entities, :viewersNum, :integer
    add_column :posts,    :viewersNum, :integer
  end
end
