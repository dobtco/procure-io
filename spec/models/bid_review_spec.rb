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
#  rating     :integer
#

require 'spec_helper'

describe BidReview do

  subject { bid_reviews(:one) }

  it { should respond_to(:starred) }
  it { should respond_to(:read) }

  it { should respond_to(:bid) }
  it { should respond_to(:officer) }
end
