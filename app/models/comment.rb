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

  validates :content, :post, :user, presence: true

  validates :uuid, uniqueness: true

  # boolean validation cannot use presence since false.blank? is true
  # validates :status, inclusion: { in: [true, false] }

  validates_associated :post, :user

  # We don't need to substract POPULARITY_BASE here because to minus a timstamp 
  # and to add another timestamp cancel out POPULARITY_BASE. Thus, it only 
  # shows the difference.
  after_create  {
    subtrahend = (self.prev ? self.prev.created_at.to_f : self.post.created_at.to_f)
    new_popularity = self.post.popularity.to_f - subtrahend + self.created_at.to_f + 300.0

    self.post.with_lock do
      self.post.update_attribute("popularity", new_popularity)
    end
  }

  before_destroy {
    addend = self.prev ? selfself.prev.created_at.to_f : self.post.created_at.to_f
    new_popularity = self.post.popularity.to_f - self.created_at.to_f + addend - 300.0

    self.post.with_lock do
      self.post.update_attribute("popularity", new_popularity)
    end
  }

  def updated_at_in_float
    updated_at.to_f
  end
  
  def created_at_in_float
    created_at.to_f
  end

  def post_uuid
    self.post.uuid
  end

  # return the next comment in the same post
  def next
    post_comments = self.post.comments #in order of id
    index = post_comments.index(self)
    return post_comments[index + 1]
  end

  # return the next comment in the same post
  def prev
    post_comments = self.post.comments #in order of id
    index = post_comments.index(self)
    new_index = index - 1
    if new_index < 0
      return nil
    else
      return post_comments[new_index]
    end
  end

end
