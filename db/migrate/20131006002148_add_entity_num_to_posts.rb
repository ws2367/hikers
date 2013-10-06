class AddEntityNumToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :entityNum, :integer, :default => 0
  end
end
