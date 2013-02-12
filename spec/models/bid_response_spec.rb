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

require 'spec_helper'

describe BidResponse do

  fixtures :all

  subject { bid_responses(:one) }

  it { should respond_to(:value) }

  it { should respond_to(:bid) }
  it { should respond_to(:response_field) }

  describe "default scope" do
    it "should sort properly" do
      BidResponse.all.should == [bid_responses(:two), bid_responses(:one)]
    end
  end
end
