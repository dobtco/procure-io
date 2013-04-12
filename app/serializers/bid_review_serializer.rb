class BidReviewSerializer < ActiveModel::Serializer
  attributes :id, :starred, :rating, :read, :created_at, :updated_at

  has_one :officer
end
