# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ActiveRecord::Base
  attr_accessible :name

  has_many :institutions
  has_many :entities, through: :institutions
  has_many :posts,    through: :entities
  has_many :comments, through: :posts
end
