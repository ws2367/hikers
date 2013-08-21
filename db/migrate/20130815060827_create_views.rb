class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.references :user
      t.references :viewee, :polymorphic => true

      t.timestamps
    end
    add_index :views, :user_id
    add_index :views, :viewee_id
  end
end
