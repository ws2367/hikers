class AddContextIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :context_id, :integer
    add_index :posts, :context_id
  end
end
