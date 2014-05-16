# == Schema Information
#
# Table name: shares
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  sharee_id   :integer
#  sharee_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  content     :text
#

# To get to the share of a specific user and a specific sharee,
#   share1 = user1.shares.where(sharee_id: 1, sharee_type: "Post").first


class Share < ActiveRecord::Base
  attr_accessible :sharee_id, :sharee_type, :user_id

  belongs_to :user
  belongs_to :sharee, polymorphic: true
  
  # validates associated followee instead of on the other end of association
  # is because follows are created after followees are created
  validates_associated :sharee, :user

  validates :sharee_type, inclusion: {in: %w(Entity Post), 
             message: "%{value} is not a valid sharee type"}

  validates :user_id, :sharee_id, :sharee_type, presence: true

end
