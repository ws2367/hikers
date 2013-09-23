class AddImgToPictures < ActiveRecord::Migration
  def self.up
    add_attachment :pictures, :img
  end

  def self.down
    remove_attachment :pictures, :img
  end
end