class ChangeUserNameAndPasswordInUsers < ActiveRecord::Migration
  def change
    change_column_null :users, :user_name, true
    change_column_null :users, :encrypted_password, true
  end
end
