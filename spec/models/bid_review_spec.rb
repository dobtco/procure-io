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

  fixtures :all

  subject { bid_reviews(:one) }

  it { should respond_to(:starred) }
  it { should respond_to(:read) }

  it { should respond_to(:bid) }
  it { should respond_to(:officer) }

  describe "calculate total stars" do
    it "should call its bids total stars method when saving" do
      bid_reviews(:one).bid.should_receive(:calculate_total_stars!)
      bid_reviews(:one).save
    end
  end
end
