class Hate < ActiveRecord::Base
  belongs_to :user
  belongs_to :hatee, polymorphic: true
  # attr_accessible :title, :body
end
