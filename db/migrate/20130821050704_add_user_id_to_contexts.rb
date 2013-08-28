class AddUserIdToContexts < ActiveRecord::Migration
  def change
    add_column :contexts, :user_id, :integer
    add_index :contexts, :user_id
  end
end
