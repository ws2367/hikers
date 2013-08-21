class Institution < ActiveRecord::Base
  attr_accessible :name

  has_many :contexts
  belongs_to :location
  has_many :posts, through: :contexts
  has_many :comments, through: :posts
  
end
