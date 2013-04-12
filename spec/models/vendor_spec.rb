# == Schema Information
#
# Table name: vendors
#
#  id               :integer          not null, primary key
#  account_disabled :boolean
#  name             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Vendor do

  subject { vendors(:one) }

  it { should respond_to(:name) }

  it { should respond_to(:bids) }
  it { should respond_to(:questions) }
  it { should respond_to(:saved_searches) }

  it { should be_valid }

  describe "bid for project" do
    it "should return the correct bid" do
      vendors(:one).bid_for_project(projects(:one)).should == bids(:one)
    end
  end

  describe "submitted bid for project" do
    it "should return the correct bid" do
      vendors(:one).submitted_bid_for_project(projects(:one)).should == bids(:one)
    end

    describe "when not submitted" do
      before { bids(:one).update_attributes(submitted_at: nil) }
      it "should return nil" do
        vendors(:one).submitted_bid_for_project(projects(:one)).should == nil
      end
    end
  end

end
