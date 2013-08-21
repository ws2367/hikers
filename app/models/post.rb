class Post < ActiveRecord::Base
  attr_accessible :content, :title, :user_id

  belongs_to :context
  belongs_to :user

  has_many :comments
  has_many :pictures
  
  has_many :follows, as: :followee
  has_many :followers, through: :follows, 
  					   source: :user

  has_many :likes,  as: :likee
  has_many :likers, through: :likes, 
  					source: :user                      
  
  has_many :hates,  as: :hatee
  has_many :haters, through: :hates, 
                    source: :user         

  has_many :views,   as: :viewee
  has_many :viewers, through: :views, 
  					 source: :user
end
