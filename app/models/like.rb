class Like < ActiveRecord::Base
  attr_accessible :user_id, :likee_id, :likee_type
  belongs_to :user
  belongs_to :likee, polymorphic: true
  # attr_accessible :title, :body
end
