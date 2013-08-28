# == Schema Information
#
# Table name: views
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  viewee_id   :integer
#  viewee_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class View < ActiveRecord::Base
  attr_accessible :user_id, :viewee_id, :viewee_type
  belongs_to :user
  belongs_to :viewee, polymorphic: true
  # attr_accessible :title, :body
end
