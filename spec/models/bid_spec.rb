# == Schema Information
#
# Table name: bids
#
#  id                      :integer          not null, primary key
#  vendor_id               :integer
#  project_id              :integer
#  body                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  submitted_at            :datetime
#  dismissed_at            :datetime
#  dismissed_by_officer_id :integer
#  total_stars             :integer          default(0), not null
#  total_comments          :integer          default(0), not null
#

require 'spec_helper'

describe Bid do

  subject { bids(:one) }

  it { should respond_to(:body) }
  it { should respond_to(:submitted_at) }
  it { should respond_to(:dismissed_at) }
  it { should respond_to(:dismissed_by_officer_id) }
  it { should respond_to(:total_stars) }
  it { should respond_to(:total_comments) }

  it { should respond_to(:project) }
  it { should respond_to(:vendor) }
  it { should respond_to(:dismissed_by_officer) }
  it { should respond_to(:bid_responses) }
  it { should respond_to(:bid_reviews) }
  it { should respond_to(:comments) }

  describe "submit" do
    before { bids(:one).update_attributes(submitted_at: nil) }
    it "should submit an unsubmitted bid" do
      bids(:one).submitted_at.should == nil
      bids(:one).submit
      bids(:one).submitted_at.should_not == nil
    end
  end

  describe "dismissed" do
    it "should return false if dismissed_at is null" do
      bids(:one).dismissed?.should == false
    end

    describe "when true" do
      before { bids(:one).dismissed_at = Time.now }
      it "should return true" do
        bids(:one).dismissed?.should == true
      end
    end
  end

  describe "dismissal" do
    before { bids(:one).dismiss_by_officer!(officers(:adam)) }
    it "dismiss_by_officer should dismiss a bid properly" do
      bids(:one).dismissed?.should == true
      bids(:one).dismissed_by_officer_id.should == officers(:adam).id
    end

    describe "when already dismissed" do
      it "dismiss_by_officer should not do anything" do
        dismissed_at = bids(:one).dismissed_at
        bids(:one).dismiss_by_officer!(officers(:clay))
        bids(:one).dismissed_by_officer_id.should == officers(:adam).id
        bids(:one).dismissed_at.should == dismissed_at
      end
    end

    describe "undismiss" do
      it "should undismiss properly" do
        bids(:one).undismiss!
        bids(:one).dismissed?.should == false
        bids(:one).dismissed_at.should == nil
        bids(:one).dismissed_by_officer_id.should == nil
      end
    end
  end

  describe "bid review for officer" do
    it "should return the correct bid review" do
      bids(:one).bid_review_for_officer(officers(:adam)).should == bid_reviews(:one)
    end

    describe "initialization" do
      before { bid_reviews(:one).destroy }
      it "should initialize a bid_review if nothing is found" do
        bids(:one).bid_review_for_officer(officers(:adam)).should be_new_record
        bids(:one).bid_review_for_officer(officers(:adam)).officer_id.should == officers(:adam).id
        bids(:one).bid_review_for_officer(officers(:adam)).bid_id.should == bids(:one).id
      end
    end
  end

  describe "calculate total stars" do
    it "should calculate total stars properly" do
      bids(:one).should_receive(:save)
      bids(:one).calculate_total_stars!
      bids(:one).total_stars.should == 1
    end

    describe "when no stars" do
      before { bid_reviews(:one).destroy }
      it "should calculate total stars properly" do
        bids(:one).calculate_total_stars!
        bids(:one).total_stars.should == 0
      end
    end
  end

  describe "calculate total comments" do
    it "should calculate total comments properly" do
      bids(:one).should_receive(:save)
      bids(:one).calculate_total_comments!
      bids(:one).total_comments.should == 1
    end

    describe "when no comments" do
      before { comments(:one).destroy }
      it "should calculate total comments properly" do
        bids(:one).calculate_total_comments!
        bids(:one).total_comments.should == 0
      end
    end
  end

end
