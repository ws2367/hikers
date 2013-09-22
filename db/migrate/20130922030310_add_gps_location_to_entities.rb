class AddGpsLocationToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :positions, :text
  end
end
