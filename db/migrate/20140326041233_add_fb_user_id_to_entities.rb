class AddFbUserIdToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :fb_user_id, :integer, :limit => 8
  end
end
