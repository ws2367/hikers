# == Schema Information
#
# Table name: hates
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  hatee_id   :integer
#  hatee_type :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hatersNum  :integer
#

require 'test_helper'

class HateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
