class RemovePositionsFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :positions
  end

  def down
    add_column :entities, :positions, :text
  end
end
