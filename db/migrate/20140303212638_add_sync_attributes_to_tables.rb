class AddSyncAttributesToTables < ActiveRecord::Migration
  def change
    add_column :posts, :deleted, :boolean, :default => false
    add_column :posts, :uuid, :string
    add_column :comments, :deleted, :string, :default => false
    add_column :comments, :uuid, :string
    add_column :entities, :uuid, :string
    add_column :institutions, :deleted, :boolean, :default => false
    add_column :institutions, :uuid, :string
  end
end
