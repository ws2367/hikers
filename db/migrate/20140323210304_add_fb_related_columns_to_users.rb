class AddFbRelatedColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_user_id, :integer
    add_column :users, :fb_access_token, :string
  end
end
