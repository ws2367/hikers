# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :integer
#  user_id    :integer
#  status     :boolean          default(TRUE)
#  hatersNum  :integer          default(0)
#  likersNum  :integer          default(0)
#  deleted    :string(255)
#  uuid       :string(255)
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
