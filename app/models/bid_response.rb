# == Schema Information
#
# Table name: bid_responses
#
#  id                :integer          not null, primary key
#  bid_id            :integer
#  response_field_id :integer
#  value             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class BidResponse < ActiveRecord::Base
  attr_accessible :bid_id, :response_field_id, :value

  belongs_to :bid
  belongs_to :response_field
end
