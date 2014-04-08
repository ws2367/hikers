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
#  deleted    :string(255)      default("f")
#  uuid       :string(255)
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id, :deleted, :uuid, :post_id

  belongs_to :post
  belongs_to :user

  # has_many :likes,  as: :likee
  # has_many :likers, through: :likes, 
  #                   source: :user                      

  # has_many :hates,  as: :hatee
  # has_many :haters, through: :hates, 
  #                   source: :user  

  validates :content, :post, :user, presence: true

  validates :content, length: {
    minimum: 1,
    maximum: 200,
    tokenizer: lambda { |str| str.scan(/\w+/) },
    too_short: "must have at least %{count} words",
    too_long: "must have at most %{count} words"
  }

  validates :uuid, uniqueness: true

  # boolean validation cannot use presence since false.blank? is true
  # validates :status, inclusion: { in: [true, false] }

  validates_associated :post, :user

  after_create  {
    self.post.with_lock do
      self.post.update_attribute("popularity", self.post.popularity.to_f + 0.6)
    end
  }

  after_destroy {
    self.post.with_lock do
      self.post.update_attribute("popularity", self.post.popularity.to_f - 0.6)
    end
  }

end
