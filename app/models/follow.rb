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
  belongs_to :followee, polymorphic: true
  # attr_accessible :title, :body
  
  # validates associated followee instead of on the other end of association
  # is because follows are created after followees are created
  validates_associated :followee, :user


  validates :followee_type, inclusion: {in: %w(Entity Post), 
  	message: "%{value} is not a valid followee type"}

  validates :user_id, :followee_id, :followee_type, presence: true
end
