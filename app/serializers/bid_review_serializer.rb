class BidReviewSerializer < ActiveModel::Serializer
  attributes :id, :starred, :rating, :read
end
