class Hate < ActiveRecord::Base
  attr_accessible :user_id, :hatee_id, :hatee_type

  belongs_to :user
  belongs_to :hatee, polymorphic: true
  # attr_accessible :title, :body
end
