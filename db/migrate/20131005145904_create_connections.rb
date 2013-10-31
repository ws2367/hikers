class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.references :entity
      t.references :post

      t.timestamps
    end
    add_index :connections, :entity_id
    add_index :connections, :post_id
  end
end
