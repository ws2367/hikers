class RemoveUuidFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :uuid
  end

  def down
    add_column :entities, :uuid, :string
  end
end

