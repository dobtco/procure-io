class BidWithReviewSerializer < BidSerializer
  attributes :my_bid_review

  def my_bid_review
    object.bid_reviews.where(officer_id: scope.id).first || object.new_bid_review_for_officer(scope)
  end
end
