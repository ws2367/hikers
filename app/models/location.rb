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

  has_many :institutions, inverse_of: :location
  has_many :entities, through: :institutions
  has_many :posts,    through: :entities
  has_many :comments, through: :posts

  validates :name, format: {with: /\A[a-zA-Z'.\-\s]+\z/, 
    message: "only allow letters, spaces, dashes, commas, dots, and apostrophes."}

  validates :name, presence: true
  # This should not be commented out when using real location libraries
  # validates :name, uniqueness: true

end
