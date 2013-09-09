class AddHatersNumToHates < ActiveRecord::Migration
  def change
    add_column :hates, :hatersNum, :integer
  end
end
