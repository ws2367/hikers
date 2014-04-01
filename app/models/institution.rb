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
#  user_id     :integer
#

class Institution < ActiveRecord::Base
  attr_accessible :name, :deleted, :uuid, :user_id, :location_id

  belongs_to :user
  belongs_to :location
  has_many   :entities, inverse_of: :institution
  has_many   :posts, through: :entities
  has_many   :comments, through: :posts

  validates :name, format: {with: /\A[a-zA-Z',.\-\s]+\z/, 
    message: "only allow letters, spaces, dashes, commas, dots, and apostrophes."}

  #For now, the presence of user_id is not required.
  validates :name, presence: true
  validates :uuid, uniqueness: true

  validates_associated :location, :user

  def self.create_institution(name, location, user_id)
    inst = nil
    if location
      if inst = location.institutions.find_by_name(name)
        #connect location to instutition just created
        inst.location_id = location.id
        return inst
      end
    end

    # if there is no location, or there is no such institution under that location
    # NOTE that we don't connect the newly created instutition to the found location
    # since location is highly detached to institution (which is school) in FB API
    unless inst = Institution.find_by_name(name)
      unless inst = Institution.create(name: name,
                                       uuid: UUIDTools::UUID.random_create.to_s,
                                       user_id: user_id)
        logger.info("Failed to create Institution #{name}.") 
        return
      end
    end
    return inst
  end
  
end
