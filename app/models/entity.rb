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
#  followersNum   :integer          default(0)
#  hatersNum      :integer          default(0)
#  likersNum      :integer          default(0)
#  viewersNum     :integer          default(0)
#  positions      :text
#  uuid           :string(255)
#  fb_user_id     :integer
#

class Entity < ActiveRecord::Base
  attr_accessible :name, :user_id, :institution_id, :uuid, :deleted, :fb_user_id
  serialize :positions

  belongs_to :institution
  belongs_to :user

  has_many :connections
  has_many :posts,     through: :connections

  has_many :friendships
  has_many :befriended_users, through: :friendships, source: :user


  has_many :comments,  through: :posts

  has_many :follows,   as: :followee
  has_many :followers, through: :follows, 
                       source:  :user

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

  validates :name, format: {with: /\A[a-zA-Z,.'\s\-]+\z/, 
    message: "only allow letters, spaces, dashes, commas, dots, and apostrophes."}

  validates :name, :user, presence: true

  validates :uuid, uniqueness: true

  validates :fb_user_id, uniqueness: true, unless: "fb_user_id.nil?"

  
  def is_friend_of_user user_id
    return ((user_id) and (self.befriended_users.exists?(user_id)))
  end

  def non_FB_entity_association
    if fb_user_id.nil?
      if institution == nil
        errors.add(:institution, "is not set on a non-FB entity")
      else
        errors.add(:customer_id, "is not active") if institution.location == nil
      end
    end
  end

  validate :non_FB_entity_association, on: :create

  validates_associated :user

  def addPosition position
    positions.push(position)
    update_attribute(:positions, positions)
  end

  def removePosition position
    if positions.delete(position) != nil
      update_attribute(:positions, positions)
      return true
    else
      return false
    end
  end

  def next
    @ent = Entity.where("id > ?", id).order("id ASC").first
    if @ent
      return @ent
    else
      return Entity.first
    end
  end

  def prev
    @ent = Entity.where("id < ?", id).order("id DESC").first
    if @ent
      return @ent
    else
      return Entity.last
    end
  end
end
