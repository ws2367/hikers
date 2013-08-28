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
#

class Hate < ActiveRecord::Base
  attr_accessible :user_id, :hatee_id, :hatee_type

  belongs_to :user
  belongs_to :hatee, polymorphic: true
  # attr_accessible :title, :body
end
