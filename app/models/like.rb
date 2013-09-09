# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  likee_id   :integer
#  likee_type :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  likersNum  :integer
#

class Like < ActiveRecord::Base
  attr_accessible :user_id, :likee_id, :likee_type
  belongs_to :user
  belongs_to :likee, polymorphic: true

  validates_associated :likee, :user

  validates :likee_type, inclusion: {in: %w(Entity Post Comment), 
  	message: "%{value} is not a valid likee type"}

  validates :likee_id, :likee_type, :user_id, presence: true
end
