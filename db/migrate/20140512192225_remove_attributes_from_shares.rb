class RemoveAttributesFromShares < ActiveRecord::Migration
  def up
    remove_column :shares, :sent_at
    remove_column :shares, :numbers
  end

  def down
    add_column :shares, :numbers, :text
    add_column :shares, :sent_at, :datetime
  end
end
