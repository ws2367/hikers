# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  content            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  post_id            :integer
#  user_id            :integer
#  deleted            :boolean          default(FALSE)
#  uuid               :string(255)
#  anonymized_user_id :integer
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id, :deleted, :uuid, :post_id, :anonymized_user_id

  belongs_to :post, counter_cache: :comments_count
  belongs_to :user

  # has_many :likes,  as: :likee
  # has_many :likers, through: :likes, 
  #                   source: :user                      

  # has_many :hates,  as: :hatee
  # has_many :haters, through: :hates, 
  #                   source: :user  

  def updated_at_in_float
    updated_at.to_f
  end

  def post_uuid
    self.post.uuid
  end

  validates :content, :post, :user, presence: true


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
