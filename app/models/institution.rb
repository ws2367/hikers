class Institution < ActiveRecord::Base
  attr_accessible :name

  has_many :entities
  belongs_to :location
  has_many :posts, through: :entities
  has_many :comments, through: :posts
  
end
