# == Schema Information
#
# Table name: friendships
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  entity_fb_user_id :integer
#

class Friendship < ActiveRecord::Base
  attr_accessible :entity_fb_user_id, :user_id

  belongs_to :entity, foreign_key: "entity_fb_user_id", primary_key: :fb_user_id, inverse_of: :friendships
  belongs_to :user

  validates :user_id, :entity_fb_user_id, presence: true

  validate :unique_friendship, on: :create

  def unique_friendship
    if Friendship.exists?(user_id: user_id, entity_fb_user_id: entity_fb_user_id)
      errors.add(:friendship, "has existed.")
    end
  end
end
