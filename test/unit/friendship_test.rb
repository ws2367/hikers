# == Schema Information
#
# Table name: friendships
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  entity_fb_user_id :integer
#

require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
