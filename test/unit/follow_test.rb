# == Schema Information
#
# Table name: follows
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  followee_id   :integer
#  followee_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  followersNum  :integer
#

require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
