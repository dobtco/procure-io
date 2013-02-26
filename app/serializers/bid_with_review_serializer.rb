class BidWithReviewSerializer < BidSerializer
  attributes :my_bid_review

  def my_bid_review
    object.my_bid_review || object.new_bid_review_for_officer(scope)
  end
end
