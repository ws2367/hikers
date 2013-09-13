class AddStatusToComments < ActiveRecord::Migration
  def change
    add_column :comments, :status, :boolean
  end
end
