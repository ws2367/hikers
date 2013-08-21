class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.references :post

      t.timestamps
    end
    add_index :pictures, :post_id
  end
end
