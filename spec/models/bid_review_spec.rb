# == Schema Information
#
# Table name: bid_reviews
#
#  id         :integer          not null, primary key
#  starred    :boolean
#  read       :boolean
#  officer_id :integer
#  bid_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  rating     :integer
#

require 'spec_helper'

describe BidReview do

  subject { bid_reviews(:one) }

  describe 'after saving' do
    it 'should perform calculations on bid' do
      bid_reviews(:one).bid.should_receive(:calculate_total_stars)
      bid_reviews(:one).bid.should_receive(:calculate_average_rating)
      bid_reviews(:one).bid.should_receive(:calculate_total_ratings)
      bid_reviews(:one).save
    end
  end
end
