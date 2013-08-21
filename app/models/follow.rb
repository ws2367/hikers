class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, polymorphic: true
  # attr_accessible :title, :body
end
