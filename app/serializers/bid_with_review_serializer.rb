class BidWithReviewSerializer < BidSerializer
  cached true

  attributes :starred, :read, :rating

  def starred
    defined?(object.starred) ? object.starred : object.bid_review_for_officer(scope.owner).starred
  end

  def read
    defined?(object.read) ? object.read : object.bid_review_for_officer(scope.owner).read
  end

  def rating
    defined?(object.rating) ? object.rating : object.bid_review_for_officer(scope.owner).rating
  end

  def cache_key
    [object.cache_key, (object.project ? object.project.cache_key : 'no-project'), (scope ? scope.cache_key : 'no-scope'), 'v8']
  end
end
