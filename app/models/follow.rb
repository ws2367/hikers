# == Schema Information
#
# Table name: follows
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  followee_id   :integer
#  followee_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

 
class Follow < ActiveRecord::Base
  attr_accessible :user_id, :followee_id, :followee_type
  belongs_to :user
  belongs_to :followee, polymorphic: true, counter_cache: :followers_count
  # attr_accessible :title, :body
  
  # validates associated followee instead of on the other end of association
  # is because follows are created after followees are created
  validates_associated :followee, :user

  validates :followee_type, inclusion: {in: %w(Entity Post), 
  	message: "%{value} is not a valid followee type"}

  validates :user_id, :followee_id, :followee_type, presence: true

  validate :unique_follow, on: :create
 
  def unique_follow
    if Follow.exists?(user_id:user_id, followee_type: 'Post', followee_id: followee_id)
      errors.add(:follow, "has existed.")
    end
  end

  after_create  {
    self.followee.with_lock do
      self.followee.update_attribute("popularity", self.followee.popularity.to_f + 150.0)
    end
  }

  before_destroy {
    self.followee.with_lock do
      self.followee.update_attribute("popularity", self.followee.popularity.to_f - 150.0)
    end
  }
  

end
