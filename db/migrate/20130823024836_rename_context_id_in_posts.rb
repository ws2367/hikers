class RenameContextIdInPosts < ActiveRecord::Migration
  def change
  	rename_column :posts, :context_id, :entity_id
  end
end
