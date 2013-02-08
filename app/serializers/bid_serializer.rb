class BidSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :submitted_at

  has_one :project
  has_one :vendor

  has_many :bid_responses
end
