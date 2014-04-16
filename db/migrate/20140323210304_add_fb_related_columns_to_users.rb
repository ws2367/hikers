class AddFbRelatedColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_user_id, :integer, :limit => 8
    add_column :users, :fb_access_token, :string
  end
end
