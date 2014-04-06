class RemoveInstitutionIdFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :institution_id
  end

  def down
    add_column :entities, :institution_id, :integer
  end
end
