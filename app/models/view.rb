class View < ActiveRecord::Base
  attr_accessible :user_id, :viewee_id, :viewee_type
  belongs_to :user
  belongs_to :viewee, polymorphic: true
  # attr_accessible :title, :body
end
