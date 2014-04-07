# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  content      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  entity_id    :integer
#  user_id      :integer
#  followersNum :integer          default(0)
#  entityNum    :integer          default(0)
#  deleted      :boolean          default(FALSE)
#  uuid         :string(255)
#  popularity   :float
#

class Post < ActiveRecord::Base
  attr_accessible :content, :user_id, :uuid, :deleted

  belongs_to :user

  has_many :connections, dependent: :destroy
  has_many :entities, through: :connections
  has_many :comments, inverse_of: :post

  has_many :befriended_users, through: :entities
  has_many :following_users, through: :follows, source: :user

  # has_many :pictures, inverse_of: :post
  
  has_many :follows,   as: :followee, dependent: :destroy
  has_many :followers, through: :follows, 
                       source: :user
 

  # has_many :likes,  as: :likee
  # has_many :likers, through: :likes, 
  #                   source: :user                      
  
  # has_many :hates,  as: :hatee
  # has_many :haters, through: :hates, 
  #                   source: :user         

  # has_many :views,   as: :viewee, dependent: :destroy
  # has_many :viewers, through: :views, 
  #                    source: :user
 
  has_many :shares,  as: :sharee, dependent: :destroy
  has_many :sharers, through: :shares, 
                     source: :user

  
  def updated_at_in_float
    updated_at.to_f
  end

  def is_by_user user_id
    return (user_id and (self.user.id == user_id))
  end

  def self.by_user user_id
    includes(:user).where("users.id = ?", user_id)
  end
  

  def is_followed_by user_id
    return (user_id and self.follows.exists?(user_id: user_id))
  end

  def self.followed_by user_id
    includes(:following_users).where("follows.user_id = ?", user_id)
  end

  # return true if the post is about a friend of the user of user_id
  def is_about_friends_of(user_id)
    return self.befriended_users.group("users.id").exists?(id: user_id)
  end
  
  def self.about_friends_of(user_id)
    includes(:befriended_users).where("friendships.user_id = ?", user_id)
  end

  # Note that this has to be a left outer join...
  scope :popular,
    includes(:entities).
    order("posts.popularity desc, posts.updated_at desc, posts.id desc")
    

  
  scope :most_followed,
    joins('LEFT OUTER JOIN follows ON follows.followee_id = posts.id AND followee_type = "Post"').
    select("posts.*, count(follows.id) as popularity").
    group("posts.id").
    order("popularity desc, updated_at desc")

  scope :most_commented,
    joins('LEFT OUTER JOIN comments ON comments.post_id = posts.id').
    select("posts.*, count(comments.id) as popularity").
    group("posts.id").
    order("popularity desc, updated_at desc")

  #TODO: remember to add 'read more'
  validates :content, length: {
    minimum: 1,
    maximum: 220,
    tokenizer: lambda { |str| str.scan(/\w+/) },
    too_short: "must have at least %{count} words",
    too_long: "must have at most %{count} words"
  }
  
  #TODO: Uncomment it when user comes alive
  #validates :content, :connection, :user, presence: true
  #validates_associated :user
  
  validates :uuid, uniqueness: true

  # boolean validation cannot use presence since false.blank? is true
  # validates :status, inclusion: { in: [true, false] }

end
