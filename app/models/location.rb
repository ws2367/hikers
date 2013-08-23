class Location < ActiveRecord::Base
  attr_accessible :name

  has_many :institutions
  has_many :entities, through: :institutions
  has_many :posts,    through: :entities
  has_many :comments, through: :posts
end
