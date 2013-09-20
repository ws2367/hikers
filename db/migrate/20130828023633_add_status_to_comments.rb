class AddStatusToComments < ActiveRecord::Migration
  def change
    add_column :comments, :status, :boolean, :default => true
  end
end
