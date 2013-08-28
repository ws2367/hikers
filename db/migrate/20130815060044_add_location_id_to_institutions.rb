class AddLocationIdToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :location_id, :integer
    add_index :institutions, :location_id
  end
end
