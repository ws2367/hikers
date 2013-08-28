class Picture < ActiveRecord::Base
  belongs_to :post
  # attr_accessible :title, :body
end
