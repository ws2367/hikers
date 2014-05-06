class AddAnonymizedUserIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :anonymized_user_id, :integer
  end
end
