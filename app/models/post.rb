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
#  status       :boolean          default(TRUE)
#  followersNum :integer          default(0)
#  hatersNum    :integer          default(0)
#  likersNum    :integer          default(0)
#  viewersNum   :integer          default(0)
#  entityNum    :integer          default(0)
#  deleted      :boolean          default(FALSE)
#  uuid         :string(255)
#

class Post < ActiveRecord::Base
  attr_accessible :content, :user_id, :uuid, :deleted

  belongs_to :user

  has_many :connections
  has_many :entities, through: :connections
  
  has_many :comments, inverse_of: :post
  has_many :pictures, inverse_of: :post
  
  has_many :follows,   as: :followee
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
 
  has_many :shares,  as: :sharee
  has_many :sharers, through: :shares, 
                     source: :user


  def isFollowing user_id
    (return 1 if self.follows.find_by_user_id(user_id) != nil) if user_id
    return 0
  end

  def popularity
    return 0.4 * self.follows.count + 0.6 * self.comments.count
  end

  # Note that this has to be a left outer join...
  scope :popular,
    joins('LEFT OUTER JOIN follows ON follows.followee_id = posts.id AND followee_type = "Post"').
    joins('LEFT OUTER JOIN comments ON comments.post_id = posts.id').
    select("posts.*, 0.4 * count(follows.id) + 0.6 * count(comments.id) as popularity").
    group("posts.id").
    order("popularity desc, updated_at desc").
    includes(entities: [:institution])
  
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
