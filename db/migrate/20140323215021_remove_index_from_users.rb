class RemoveIndexFromUsers < ActiveRecord::Migration
  def change
    remove_index :users, :user_name
    remove_index :users, :reset_password_token
  end
end
