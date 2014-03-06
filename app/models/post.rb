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
#  deleted      :boolean
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


  #def get_picture index
  #  send_file pictures[index].img.path, :type => pictures[index].img_content_type
  #end

  # img is a File object
  #def create_picture img
  #  @pic = pictures.new
  #  @pic.img = img
  #  @pic.save
    # pictures.first.img = fp
    # pictures.first.save
  #end

  #TODO: remember to add 'read more'
  validates :content, length: {
    minimum: 1,
    maximum: 400,
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
