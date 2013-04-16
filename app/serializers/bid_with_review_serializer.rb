class BidWithReviewSerializer < BidSerializer
  cached true

  has_one :my_bid_review

  def my_bid_review
    object.bid_reviews.where(officer_id: scope.owner.id).first || object.new_bid_review_for_officer(scope.owner)
  end

  def include_my_bid_review?
    scope
  end

  def cache_key
    [object.cache_key, (scope ? scope.id : 0), 'v2']
  end
end
