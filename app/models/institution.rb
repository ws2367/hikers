# == Schema Information
#
# Table name: institutions
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#  deleted     :boolean          default(FALSE)
#  uuid        :string(255)
#

class Institution < ActiveRecord::Base
  attr_accessible :name, :deleted, :uuid

  belongs_to :user
  belongs_to :location
  has_many   :entities, inverse_of: :institution
  has_many   :posts, through: :entities
  has_many   :comments, through: :posts

  validates :name, format: {with: /\A[a-zA-Z',.\-\s]+\z/, 
    message: "only allow letters, spaces, dashes, commas, dots, and apostrophes."}

  #For now, the presence of user_id is not required.
  validates :name, :location, presence: true
  validates :uuid, uniqueness: true

  validates_associated :location, :user
end
