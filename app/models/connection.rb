# == Schema Information
#
# Table name: connections
#
#  id         :integer          not null, primary key
#  entity_id  :integer
#  post_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Connection < ActiveRecord::Base
  attr_accessible :entity_id, :post_id

  belongs_to :entity
  belongs_to :post

  validates :post_id, :entity_id, presence: true
  validates_associated :post, :entity
end
