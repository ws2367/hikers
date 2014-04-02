# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  user_name              :string(255)      default("")
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  status                 :boolean          default(TRUE)
#  device_token           :string(255)
#  authentication_token   :string(255)
#  fb_user_id             :integer
#  fb_access_token        :string(255)
#

class User < ActiveRecord::Base

  #before_filter :authenticate_user! 

  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :token_authenticatable, 
         :rememberable, :trackable, :validatable, :authentication_keys => [:fb_user_id]

  # Seems like we don't need to do it in Rails 4 since it's all strong params
  # Setup accessible (or protected) attributes for your model
  attr_accessible :fb_user_id, :fb_access_token, :user_name, :password, :password_confirmation, :remember_me, :login

# Virtual attribute for authenticating by either user_name or device_token
# This is in addition to a real persisted field like 'user_name'
attr_accessor :login

#authentication key can be either user_name or device_token
#def self.find_first_by_auth_conditions(warden_conditions)
#  conditions = warden_conditions.dup
#  if login = conditions.delete(:login)
#    where(conditions).where(["lower(user_name) = :value OR lower(device_token) = :value", { :value => login.downcase }]).first
#  else
#    where(conditions).first
#  end
#end

#rewrite the method so we don't need email
def password_required?
  false
end

#rewrite the method so we don't need email
def email_required? 
  false
end

#rewrite the method so we don't need email
def email_changed?
  false
end

def next
  User.where("id > ?", id).order("id ASC").first
end

def prev
  User.where("id < ?", id).order("id DESC").first
end


# validates :user_name,
#   :uniqueness => {
#     :case_sensitive => false
#   }

has_many :institution, inverse_of: :user
has_many :entities,    inverse_of: :user
has_many :posts,       inverse_of: :user
has_many :comments,    inverse_of: :user

has_many :follows, inverse_of: :user, dependent: :destroy
has_many :likes,   inverse_of: :user
has_many :hates,   inverse_of: :user
has_many :views,   inverse_of: :user
has_many :shares,  inverse_of: :user

has_many :friendships, dependent: :destroy
has_many :friends, through: :friendships

has_many :followedEntities, through: :follows, 
                            source: "followee",
                            source_type: "Entity"
has_many :followedPosts,    through: :follows, 
                            source: "followee",
                            source_type: "Post"

has_many :likedEntities,    through: :likes, 
                            source: "likee",
                            source_type: "Entity"
has_many :likedPosts,       through: :likes, 
                            source: "likee",
                            source_type: "Post"
has_many :likedComments,    through: :likes, 
                            source: "likee",
                            source_type: "Comment"

has_many :hatedEntities,    through: :hates, 
                            source: "hatee",
                            source_type: "Entity"
has_many :hatedPosts,       through: :hates, 
                            source: "hatee",
                            source_type: "Post"
has_many :hatedComments,    through: :hates, 
                            source: "hatee",
                            source_type: "Comment"

has_many :viewedEntities,   through: :views, 
                            source: "viewee",
                            source_type: "Entity"
has_many :viewedPosts,      through: :views, 
                            source: "viewee",
                            source_type: "Post"

has_many :sharedEntities,   through: :shares, 
                            source: "sharee",
                            source_type: "Entity"
has_many :sharedPosts,      through: :shares, 
                            source: "sharee",
                            source_type: "Post"

end
