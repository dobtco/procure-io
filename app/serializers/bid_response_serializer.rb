class BidResponseSerializer < ActiveModel::Serializer
  attributes :id, :bid_id, :response_field_id, :value, :display_value

  has_one :response_field
end
