class BidForCommentSerializer < ActiveModel::Serializer
  attributes :id

  has_one :vendor
end
