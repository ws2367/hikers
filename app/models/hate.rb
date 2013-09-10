# == Schema Information
#
# Table name: hates
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  hatee_id   :integer
#  hatee_type :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Hate < ActiveRecord::Base
  attr_accessible :user_id, :hatee_id, :hatee_type

  belongs_to :user
  belongs_to :hatee, polymorphic: true
  # attr_accessible :title, :body

  validates_associated :hatee, :user

  validates :hatee_type, inclusion: {in: %w(Entity Post Comment), 
  	message: "%{value} is not a valid hatee type"}

  validates :user_id, :hatee_id, :hatee_type, presence: true
end
