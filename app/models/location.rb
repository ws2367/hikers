class Location < ActiveRecord::Base
  attr_accessible :name

  has_many :institutions
  has_many :contexts, through: :institutions
  has_many :posts,    through: :contexts
  has_many :comments, through: :posts
end
