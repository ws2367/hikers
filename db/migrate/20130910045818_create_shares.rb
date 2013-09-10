class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.references :user
      t.references :sharee, :polymorphic => true
      t.text :numbers
      t.datetime :sent_at # the latest sent time
      t.timestamps
    end
  end
end
