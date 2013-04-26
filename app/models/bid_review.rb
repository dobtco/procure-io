# == Schema Information
#
# Table name: bid_reviews
#
#  id         :integer          not null, primary key
#  starred    :boolean
#  read       :boolean
#  officer_id :integer
#  bid_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rating     :integer
#

class BidReview < ActiveRecord::Base
  belongs_to :bid
  belongs_to :officer

  after_save :perform_calculations_on_bid!

  scope :that_have_ratings, where("rating IS NOT NULL")

  private
  def perform_calculations_on_bid!
    bid.calculate_total_stars
    bid.calculate_average_rating
    bid.calculate_total_ratings
    bid.save
  end
end
