class AddFbRelatedColumnsToUsers < ActiveRecord::Migration
  def change
    change_column :users, :user_name,          :null => true, :default => ""
    change_column :users, :encrypted_password, :null => true, :default => ""
  end
end
