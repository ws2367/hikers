# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entity_id  :integer
#  user_id    :integer
#  status     :boolean
#

class Post < ActiveRecord::Base
  attr_accessible :content, :user_id

  belongs_to :entity
  belongs_to :user

  has_many :comments, inverse_of: :post
  has_many :pictures, inverse_of: :post
  
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

  #TODO: remember to add 'read more'
  validates :content, length: {
    minimum: 1,
    maximum: 400,
    tokenizer: lambda { |str| str.scan(/\w+/) },
    too_short: "must have at least %{count} words",
    too_long: "must have at most %{count} words"
  }
  
  validates :content, :entity, :user, presence: true

  # boolean validation cannot use presence since false.blank? is true
  # validates :status, inclusion: { in: [true, false] }

  validates_associated :entity, :user
end
