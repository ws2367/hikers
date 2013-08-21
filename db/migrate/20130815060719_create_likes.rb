class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :state
      t.references :user
      t.references :likee, :polymorphic => true

      t.timestamps
    end
    add_index :likes, :user_id
    add_index :likes, :likee_id
  end
end
