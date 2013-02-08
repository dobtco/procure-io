# == Schema Information
#
# Table name: bid_reviews
#
#  id         :integer          not null, primary key
#  starred    :boolean
#  read       :boolean
#  officer_id :integer
#  bid_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BidReview < ActiveRecord::Base
  # @todo better scoping
  attr_accessible :bid_id, :officer_id, :read, :starred

  belongs_to :bid
  belongs_to :officer
end
