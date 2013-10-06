# == Schema Information
#
# Table name: pictures
#
#  id               :integer          not null, primary key
#  post_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  img_file_name    :string(255)
#  img_content_type :string(255)
#  img_file_size    :integer
#  img_updated_at   :datetime
#

require 'test_helper'

class PictureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
