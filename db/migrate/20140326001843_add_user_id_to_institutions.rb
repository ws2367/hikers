class AddUserIdToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :user_id, :integer
  end
end
