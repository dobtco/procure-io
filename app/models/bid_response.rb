class BidResponse < ActiveRecord::Base
  attr_accessible :bid_id, :response_field_id, :value

  belongs_to :bid
  belongs_to :response_field
end
