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

require 'spec_helper'

describe BidReview do
  pending "add some examples to (or delete) #{__FILE__}"
end
