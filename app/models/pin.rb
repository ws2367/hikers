# == Schema Information
#
# Table name: pins
#
#  id                 :integer          not null, primary key
#  description        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  user_id            :integer
#  image_remote_url   :string(255)
#

class Pin < ActiveRecord::Base
      attr_accessible :description, :image, :image_remote_url

      belongs_to :user
      validates :user_id, presence: true
      validates :description, presence: true
      validates_attachment :image, presence: true,
                           content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
                           size: { less_than: 5.megabytes} 
  
      has_attached_file :image, styles: {medium: "320x240>"}

      def image_remote_url=(url_value) 
          self.image = URI.parse(url_value) unless url_value.blank?
          super 
      end

end
