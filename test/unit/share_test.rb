# == Schema Information
#
# Table name: shares
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  sharee_id   :integer
#  sharee_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  content     :text
#

require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
