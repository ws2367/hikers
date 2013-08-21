class CreateHates < ActiveRecord::Migration
  def change
    create_table :hates do |t|
      t.references :user
      t.references :hatee, :polymorphic => true

      t.timestamps
    end
    add_index :hates, :user_id
    add_index :hates, :hatee_id
  end
end
