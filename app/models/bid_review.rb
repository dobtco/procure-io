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
  belongs_to :bid, touch: true
  belongs_to :officer

  after_save :calculate_bid_total_stars_and_average_rating!

  scope :that_have_ratings, where("rating IS NOT NULL")

  private
  def calculate_bid_total_stars_and_average_rating!
    bid.calculate_total_stars
    bid.calculate_average_rating
    bid.calculate_total_ratings
    bid.save
  end
end
