# == Schema Information
#
# Table name: bid_reviews
#
#  id         :integer          not null, primary key
#  starred    :boolean
#  read       :boolean
#  user_id    :integer
#  bid_id     :integer
#  rating     :integer
#  created_at :datetime
#  updated_at :datetime
#

class BidReview < ActiveRecord::Base
  belongs_to :bid, touch: true # redundant, but perform_calculations_on_bid! was not updating the timestamp.
  belongs_to :user

  after_save :perform_calculations_on_bid!

  scope :that_have_ratings, -> { where("rating IS NOT NULL") }

  private
  def perform_calculations_on_bid!
    bid.calculate_total_stars
    bid.calculate_average_rating
    bid.calculate_total_ratings
    bid.save
  end
end
