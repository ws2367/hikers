# == Schema Information
#
# Table name: entities
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :integer
#  user_id        :integer
#

class Entity < ActiveRecord::Base
  attr_accessible :name, :user_id, :institution_id
  
  belongs_to :institution
  belongs_to :user

  has_many :posts
  has_many :comments,  through: :posts

  has_many :follows,   as: :followee
  has_many :followers, through: :follows, 
                       source:    :user

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
