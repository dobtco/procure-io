class BidWithReviewSerializer < BidSerializer
  cached true

  attributes :starred, :read, :rating

  def cache_key
    keys = [object.cache_key, scope ? scope.cache_key : 'no-scope', 'v4']
  end
end
