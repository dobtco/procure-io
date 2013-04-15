class BidWithReviewSerializer < BidSerializer
  cached true

  has_one :my_bid_review

  def my_bid_review
    object.bid_reviews.where(officer_id: scope.id).first || object.new_bid_review_for_officer(scope)
  end

  def cache_key
    object.cache_key
  end
end
