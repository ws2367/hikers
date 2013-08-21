class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :viewee, polymorphic: true
  # attr_accessible :title, :body
end
