# == Schema Information
#
# Table name: shares
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  sharee_id   :integer
#  sharee_type :string(255)
#  numbers     :text
#  sent_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# To get to the share of a specific user and a specific sharee,
#   share1 = user1.shares.where(sharee_id: 1, sharee_type: "Post").first
#
# To manipulate the array of numbers,
#   share1.numbers.include?(2122394356)
#   share1.numbers.count
#   share1.numbers.push(4393042950) : add to the end of an array
#   share1.numbers.unshift(4393042950) : add to the beginning of an array 
#   share1.numbers.delete(4393042950) : delete this number
#   
# ref: http://www.ruby-doc.org/core-2.0.0/Array.html


class Share < ActiveRecord::Base
  attr_accessible :numbers, :sharee_id, :sharee_type, :user_id
  serialize :numbers

  belongs_to :user
  belongs_to :sharee, polymorphic: true
  
  # validates associated followee instead of on the other end of association
  # is because follows are created after followees are created
  validates_associated :sharee, :user

  validates :sharee_type, inclusion: {in: %w(Entity Post), 
             message: "%{value} is not a valid sharee type"}

  validates :user_id, :sharee_id, :sharee_type, presence: true

  def addNum(num)
    numbers.push(num)
  end

  def removeNum(num)
    return numbers.delete(num) != nil
  end

  def incNum?(num)
    return numbers.include?(num)
  end
end
