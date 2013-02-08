# == Schema Information
#
# Table name: bids
#
#  id           :integer          not null, primary key
#  vendor_id    :integer
#  project_id   :integer
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  submitted_at :datetime
#

class Bid < ActiveRecord::Base
  # @todo better scopes
  attr_accessible :body, :project_id

  belongs_to :project
  belongs_to :vendor

  has_many :bid_responses, dependent: :destroy
  has_many :bid_reviews

  def submit
    self.submitted_at = Time.now
  end

  def bid_review_for_officer(officer)
    bid_reviews.where(officer_id: officer.id).first_or_initialize
  end

  def total_stars
    bid_reviews.where(starred: true).count
  end
end
