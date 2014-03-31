# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  entity_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Friendship < ActiveRecord::Base
  attr_accessible :entity_id, :user_id

  belongs_to :entity
  belongs_to :user

  validates_associated :entity, :user

  validates :user_id, :entity_id, presence: true

  validate :unique_friendship, on: :create

  def unique_friendship
    if Friendship.where("user_id = ? AND entity_id = ?", user_id, entity_id).count > 0
      errors.add(:friendship, "has existed.")
    end
  end
end
