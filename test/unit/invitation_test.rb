# == Schema Information
#
# Table name: invitations
#
#  id               :integer          not null, primary key
#  inviter_name     :string(255)
#  inviter_birthday :string(255)
#  inviter_fb_id    :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
