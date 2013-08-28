# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :integer
#  user_id    :integer
#  status     :boolean
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id

  belongs_to :post
  belongs_to :user

  has_many :likes,  as: :likee
  has_many :likers, through: :likes, 
  					source: :user                      

  has_many :hates,  as: :hatee
  has_many :haters, through: :hates, 
                    source: :user         
end
