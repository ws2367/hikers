class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :likee, polymorphic: true
  # attr_accessible :title, :body
end
