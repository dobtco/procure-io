class BidWithReviewSerializer < BidSerializer
  attributes :my_bid_review, :total_stars

  def my_bid_review
    object.bid_review_for_officer(scope)
  end
end
