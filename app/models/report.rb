class Report < ActiveRecord::Base
  attr_accessible :post_id, :user_id

  belongs_to :user
  belongs_to :post

  validates :post_id, :user_id, presence: true

  validate :unique_report, on: :create
 
  def unique_report
    if Report.exists?(user_id:user_id, post_id: post_id)
      errors.add(:report, "has existed.")
    end
  end
end
