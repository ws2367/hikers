class RenameContextToEntity < ActiveRecord::Migration
  def change 
  	rename_table :contexts, :entities
  end

end
