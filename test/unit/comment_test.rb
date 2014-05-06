# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  content            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  post_id            :integer
#  user_id            :integer
#  deleted            :boolean          default(FALSE)
#  uuid               :string(255)
#  anonymized_user_id :integer
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
