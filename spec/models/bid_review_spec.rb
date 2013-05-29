# == Schema Information
#
# Table name: bid_reviews
#
#  id         :integer          not null, primary key
#  starred    :boolean
#  read       :boolean
#  user_id    :integer
#  bid_id     :integer
#  rating     :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe BidReview do
  before do
    @bid_review = FactoryGirl.build(:bid_review)
  end

  subject { @bid_review }

  describe 'after saving' do
    before do
      @bid_review.stub(:bid).and_return(OpenStruct.new)
    end
    it 'should perform calculations on bid' do
      @bid_review.bid.should_receive(:calculate_total_stars)
      @bid_review.bid.should_receive(:calculate_average_rating)
      @bid_review.bid.should_receive(:calculate_total_ratings)
      @bid_review.save
    end
  end
end
