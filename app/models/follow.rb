class Follow < ActiveRecord::Base
  attr_accessible :user_id, :followee_id, :followee_type
  belongs_to :user
  belongs_to :followee, polymorphic: true
  # attr_accessible :title, :body
end
