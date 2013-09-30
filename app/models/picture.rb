# == Schema Information
#
# Table name: pictures
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Picture < ActiveRecord::Base
  belongs_to :post
  
  attr_accessible :img, :post_id

  # This method associates the attribute ":img" with a file attachment
  has_attached_file :img, styles: {
		    thumb: ['100x100>', :jpg],
		    square: ['200x200#', :jpg],
		    medium: ['300x300>', :jpg]
		  },
      :default_url => :medium,
		  :path => 'pictures/:id/:style.jpg',
  		:url => '/:class/:id/:attachment'

  validates :img,  attachment_presence: true
  validates :post, presence: true
  validates_associated :post

  # validates_attachment :img, presence: true,
  # size: { less_than: 5.megabytes},
  # content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] }
  
  #def get_picture(post_id, index)
  #  @post = Post.find(post_id)
  #  send_file @post.pictures[index].img.path, :type => @post.pictures[index].img_content_type
  #end

  # img is a File object
  #def create_picture(post_id, img)
  #  self.post_id = post_id
  #  self.img = img
  #  self.save
    # pictures.first.img = fp
    # pictures.first.save
  #end
  
  def image_remote_url=(url_value)
    self.img = URI.parse(url_value) unless url_value.blank?
    super
  end

  
end