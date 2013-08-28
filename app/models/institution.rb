# == Schema Information
#
# Table name: institutions
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#

class Institution < ActiveRecord::Base
  attr_accessible :name

  has_many :entities
  belongs_to :location
  has_many :posts, through: :entities
  has_many :comments, through: :posts
  
end
