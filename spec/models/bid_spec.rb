# == Schema Information
#
# Table name: bids
#
#  id                      :integer          not null, primary key
#  vendor_id               :integer
#  project_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  submitted_at            :datetime
#  dismissed_at            :datetime
#  dismissed_by_officer_id :integer
#  total_stars             :integer          default(0), not null
#  total_comments          :integer          default(0), not null
#  awarded_at              :datetime
#  awarded_by_officer_id   :integer
#  average_rating          :decimal(3, 2)
#

require 'spec_helper'

describe Bid do

  subject { bids(:one) }

  it { should respond_to(:submitted_at) }
  it { should respond_to(:dismissed_at) }
  it { should respond_to(:dismissed_by_officer_id) }
  it { should respond_to(:total_stars) }
  it { should respond_to(:total_comments) }

  it { should respond_to(:project) }
  it { should respond_to(:vendor) }
  it { should respond_to(:dismissed_by_officer) }
  it { should respond_to(:responses) }
  it { should respond_to(:bid_reviews) }
  it { should respond_to(:comments) }
  it { should respond_to(:labels) }

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
        bids(:one).undismiss_by_officer!(officers(:adam))
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

  describe "awarding" do
    it { should_not be_awarded }

    describe "when awarded" do
      before { bids(:one).awarded_at = Time.now }
      it { should be_awarded }
    end

    describe "award by officer" do
      it { should_not be_awarded }
      it "should correctly award by officer" do
        bids(:one).should_not_receive(:save)
        bids(:one).awarded_at.should be_nil
        bids(:one).award_by_officer(officers(:adam))
        bids(:one).awarded_at.should_not be_nil
        bids(:one).awarded_by_officer_id.should == officers(:adam).id
      end

      it "should save when using award_by_officer!" do
        bids(:one).should_receive(:save)
        bids(:one).award_by_officer!(officers(:adam))
      end
    end

    describe "unaward by officer" do
      before { bids(:one).award_by_officer!(officers(:adam)) }

      it "should correctly unaward by officer" do
        bids(:one).should_not_receive(:save)
        bids(:one).awarded_at.should_not be_nil
        bids(:one).unaward_by_officer(officers(:adam))
        bids(:one).awarded_at.should be_nil
        bids(:one).awarded_by_officer_id.should be_nil
      end

      it "should save when using unaward_by_officer!" do
        bids(:one).should_receive(:save)
        bids(:one).unaward_by_officer!(officers(:adam))
      end
    end
  end

  describe "validation" do
    pending
  end
end
