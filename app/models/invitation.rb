# == Schema Information
#
# Table name: invitations
#
#  id               :integer          not null, primary key
#  inviter_name     :string(255)
#  inviter_birthday :string(255)
#  inviter_fb_id    :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Invitation < ActiveRecord::Base
  attr_accessible :inviter_name, :inviter_birthday, :inviter_fb_id, :user_id

  belongs_to :user

  validates :inviter_fb_id, uniqueness: true
  validates :inviter_name, :inviter_fb_id, presence: true
end
