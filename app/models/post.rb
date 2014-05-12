# == Schema Information
#
# Table name: posts
#
#  id              :integer          not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  followers_count :integer          default(0)
#  deleted         :boolean          default(FALSE)
#  uuid            :string(255)
#  popularity      :float            default(0.0)
#  comments_count  :integer          default(0)
#  is_active       :boolean          default(FALSE)
#

class Post < ActiveRecord::Base
  attr_accessible :content, :user_id, :uuid, :deleted

  belongs_to :user

  has_many :reports, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :entities, through: :connections
  has_many :comments, inverse_of: :post

  has_many :befriended_users, through: :entities
  has_many :following_users, through: :follows, source: :user
  
  has_many :follows,   as: :followee, dependent: :destroy
  has_many :followers, through: :follows, 
                       source: :user
 
  has_many :shares,  as: :sharee, dependent: :destroy
  has_many :sharers, through: :shares, 
                     source: :user

  validates :content, :connection, :user, presence: true
  validates_associated :user
  
  validates :uuid, uniqueness: true

  # popularity = tc + tp + nc*300 + nf*150
  # tc: creation time of the last comment
  # tp: creation time of the post
  # nc: # of comments
  # nf: # of follows
  # POPULARITY_BASE: Tue, 01 Apr 2014 00:00:00 GMT
  POPULARITY_BASE = 1396310400.0
  
  after_create {
    self.with_lock do
      self.update_attribute("popularity", (self.created_at.to_f - POPULARITY_BASE) * 2)
    end
  }

  def updated_at_in_float
    updated_at.to_f
  end

  def self.fetch_segment(query_result, start_over, last_of_previous_post_ids)
    if start_over
      posts = query_result.limit(5)
    else
      start_index  = query_result.index{|post| post.id == last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = query_result.all.count
        end_index = [(start_index + 4), (count - 1)].min
        logger.info "start_index: " + start_index.to_s + " end_index: " + end_index.to_s
        # Note that if a < b, Array.slice(b..a) returns [] which is desired
        posts = query_result.slice(start_index..end_index)
      else
        posts = Array.new
      end
    end
    return posts
  end


  def self.query_popular_posts(user_id, start_over, last_of_previous_post_ids)
    query_result = Post.active.popular
    return fetch_segment(query_result, start_over, last_of_previous_post_ids)
  end

  def self.query_friends_posts(user_id, start_over, last_of_previous_post_ids)
    query_result = Post.active.about_friends_of(user_id).popular
    return fetch_segment(query_result, start_over, last_of_previous_post_ids)
  end

  def self.query_following_posts(user_id, start_over, last_of_previous_post_ids)
    query_result = Post.active.followed_by(user_id).popular
    return fetch_segment(query_result, start_over, last_of_previous_post_ids)
  end

  def self.query_posts_about_me(user_id, start_over, last_of_previous_post_ids)
    query_result = Post.active.about_user(user_id).popular
    return fetch_segment(query_result, start_over, last_of_previous_post_ids)
  end

  def self.query_my_posts(user_id, start_over, last_of_previous_post_ids)
    query_result = Post.active.by_user(user_id).popular
    return fetch_segment(query_result, start_over, last_of_previous_post_ids)
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

  #TODO: here it should be rewritten using joins, not where which is slower
  def self.about_user(user_id)
    user = User.find_by_id(user_id)
    unless user 
      logger.info("[ERROR] Invalid user_id while querying posts about the user")
      return nil  
    end
    fb_user_id = user.fb_user_id
    return includes(:entities).where("entities.fb_user_id = ?", fb_user_id)
  end

  scope :active,
    where("is_active = ?", true)

  scope :inactive,
    where("is_active = ?", false)

  # Note that this has to be a left outer join...
  scope :popular,
    includes(:entities).
    order("posts.popularity desc, posts.updated_at desc, posts.id desc")
    
  
  scope :most_followed,
    joins('LEFT OUTER JOIN follows ON follows.followee_id = posts.id AND followee_type = "Post"').
    select("posts.*, count(follows.id) as follow_count").
    group("posts.id").
    order("follow_count desc, updated_at desc")

  scope :most_commented,
    joins('LEFT OUTER JOIN comments ON comments.post_id = posts.id').
    select("posts.*, count(comments.id) as comment_count").
    group("posts.id").
    order("comment_count desc, updated_at desc")

  # validates :content, length: {
  #   minimum: 1,
  #   maximum: 220,
  #   tokenizer: lambda { |str| str.scan(/\w+/) },
  #   too_short: "must have at least %{count} words",
  #   too_long: "must have at most %{count} words"
  # }
  

end
