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
#  followersNum :integer          default(0)
#  entityNum    :integer          default(0)
#  deleted      :boolean          default(FALSE)
#  uuid         :string(255)
#  popularity   :float
#

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
