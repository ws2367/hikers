class AddInstitutionIdToContexts < ActiveRecord::Migration
  def change
    add_column :contexts, :institution_id, :integer
    add_index :contexts, :institution_id
  end
end
