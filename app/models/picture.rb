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
  # attr_accessible :title, :body
end
