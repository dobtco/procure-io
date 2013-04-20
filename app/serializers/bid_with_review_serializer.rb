class BidWithReviewSerializer < BidSerializer
  # cached true

  attributes :starred, :read, :rating

  def cache_key
    keys = [object.cache_key, 'v3']
    keys.push(scope.cache_key, scope.owner.cache_key) if scope
    keys
  end
end
