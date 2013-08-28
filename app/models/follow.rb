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
#

class Follow < ActiveRecord::Base
  attr_accessible :user_id, :followee_id, :followee_type
  belongs_to :user
  belongs_to :followee, polymorphic: true
  # attr_accessible :title, :body
end
