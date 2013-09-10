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
#  hatersNum  :integer
#  likersNum  :integer
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

  validates :content, :post, :user, presence: true

  validates :content, length: {
    minimum: 1,
    maximum: 200,
    tokenizer: lambda { |str| str.scan(/\w+/) },
    too_short: "must have at least %{count} words",
    too_long: "must have at most %{count} words"
  }

  # boolean validation cannot use presence since false.blank? is true
  # validates :status, inclusion: { in: [true, false] }

  validates_associated :post, :user
end
