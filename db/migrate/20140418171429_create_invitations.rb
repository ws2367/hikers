class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :inviter_name
      t.string :inviter_birthday
      t.string :inviter_fb_id
      t.references :user
      
      t.timestamps
    end
  end
end
