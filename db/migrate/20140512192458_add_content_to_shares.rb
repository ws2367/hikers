class AddContentToShares < ActiveRecord::Migration
  def change
    add_column :shares, :content, :text
  end
end
