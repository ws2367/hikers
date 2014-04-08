class AddInstituionAndLocationToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :institution, :string
    add_column :entities, :location, :string
  end
end
