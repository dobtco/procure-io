class BidReview < ActiveRecord::Base
  # @todo better scoping
  attr_accessible :bid_id, :officer_id, :read, :starred

  belongs_to :bid
  belongs_to :officer
end
