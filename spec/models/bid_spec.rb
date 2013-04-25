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
#  total_ratings           :integer
#

require 'spec_helper'

describe Bid do

  subject { bids(:one) }

  describe 'Bid#add_params_to_query' do
    before { @query = FakeQuery.new }

    describe 'the f2 query parameter' do
      it 'should filter for dismissed' do
        @query.should_receive(:dismissed).and_return(@query)
        Bid.add_params_to_query(@query, f2: 'dismissed')
      end

      it 'should filter for awarded' do
        @query.should_receive(:awarded).and_return(@query)
        Bid.add_params_to_query(@query, f2: 'awarded')
      end

      it 'should default to filtering for open bids' do
        @query.should_receive(:where_open).and_return(@query)
        Bid.add_params_to_query(@query, {})
      end
    end

    describe 'the f1 query parameter' do
      it 'should filter for starred' do
        @query.should_receive(:starred).and_return(@query)
        Bid.add_params_to_query(@query, f1: 'starred')
      end
    end

    describe 'the label parameter' do
      it 'should filter by labels' do
        @query.should_receive(:join_labels).and_return(@query)
        Bid.add_params_to_query(@query, label: 'Foo')
      end

      it 'should not filter if blank' do
        @query.should_not_receive(:join_labels)
        Bid.add_params_to_query(@query, label: '')
      end
    end

    describe 'the sort parameter' do
      it 'should sort by vendors.name if blank' do
        @query.should_receive(:order).with(/vendors\.name/).and_return(@query)
        Bid.add_params_to_query(@query, sort: '')
      end
    end

    describe 'the q parameter' do
      it 'should perform a full search' do
        @query.should_receive(:full_search).with('Foo').and_return(@query)
        Bid.add_params_to_query(@query, q: 'Foo')
      end

      it 'should not search if blank' do
        @query.should_not_receive(:full_search)
        Bid.add_params_to_query(@query, q: '')
      end
    end
  end

  describe 'Bid#search_meta_info' do
    it 'should calculate counts for other searches' do
      expected_new_hash = hash_including(count_only: true, starting_query: 'Foo')
      Bid.should_receive(:searcher).with(hash_including(f1: 'open'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(f1: 'starred'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(f2: 'open'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(f2: 'dismissed'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(f2: 'awarded'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(label: 'bar'), expected_new_hash)

      Bid.search_meta_info({}, { simpler_query: 'Foo', project: mock(labels: [mock(id: 0, name: 'bar')]) })
    end
  end


  # describe "submit" do
  #   before { bids(:one).update_attributes(submitted_at: nil) }
  #   it "should submit an unsubmitted bid" do
  #     bids(:one).submitted_at.should == nil
  #     bids(:one).submit
  #     bids(:one).submitted_at.should_not == nil
  #   end
  # end

  # describe "dismissed" do
  #   it "should return false if dismissed_at is null" do
  #     bids(:one).dismissed?.should == false
  #   end

  #   describe "when true" do
  #     before { bids(:one).dismissed_at = Time.now }
  #     it "should return true" do
  #       bids(:one).dismissed?.should == true
  #     end
  #   end
  # end

  # describe "dismissal" do
  #   before { bids(:one).dismiss_by_officer!(officers(:adam)) }
  #   it "dismiss_by_officer should dismiss a bid properly" do
  #     bids(:one).dismissed?.should == true
  #     bids(:one).dismissed_by_officer_id.should == officers(:adam).id
  #   end

  #   describe "when already dismissed" do
  #     it "dismiss_by_officer should not do anything" do
  #       dismissed_at = bids(:one).dismissed_at
  #       bids(:one).dismiss_by_officer!(officers(:clay))
  #       bids(:one).dismissed_by_officer_id.should == officers(:adam).id
  #       bids(:one).dismissed_at.should == dismissed_at
  #     end
  #   end

  #   describe "undismiss" do
  #     it "should undismiss properly" do
  #       bids(:one).undismiss_by_officer!(officers(:adam))
  #       bids(:one).dismissed?.should == false
  #       bids(:one).dismissed_at.should == nil
  #       bids(:one).dismissed_by_officer_id.should == nil
  #     end
  #   end
  # end

  # describe "bid review for officer" do
  #   it "should return the correct bid review" do
  #     bids(:one).bid_review_for_officer(officers(:adam)).should == bid_reviews(:one)
  #   end

  #   describe "initialization" do
  #     before { bid_reviews(:one).destroy }
  #     it "should initialize a bid_review if nothing is found" do
  #       bids(:one).bid_review_for_officer(officers(:adam)).should be_new_record
  #       bids(:one).bid_review_for_officer(officers(:adam)).officer_id.should == officers(:adam).id
  #       bids(:one).bid_review_for_officer(officers(:adam)).bid_id.should == bids(:one).id
  #     end
  #   end
  # end

  # describe "calculate total stars" do
  #   it "should calculate total stars properly" do
  #     bids(:one).should_receive(:save)
  #     bids(:one).calculate_total_stars!
  #     bids(:one).total_stars.should == 1
  #   end

  #   describe "when no stars" do
  #     before { bid_reviews(:one).destroy }
  #     it "should calculate total stars properly" do
  #       bids(:one).calculate_total_stars!
  #       bids(:one).total_stars.should == 0
  #     end
  #   end
  # end

  # describe "calculate total comments" do
  #   it "should calculate total comments properly" do
  #     bids(:one).should_receive(:save)
  #     bids(:one).calculate_total_comments!
  #     bids(:one).total_comments.should == 1
  #   end

  #   describe "when no comments" do
  #     before { comments(:one).destroy }
  #     it "should calculate total comments properly" do
  #       bids(:one).calculate_total_comments!
  #       bids(:one).total_comments.should == 0
  #     end
  #   end
  # end

  # describe "awarding" do
  #   it { should_not be_awarded }

  #   describe "when awarded" do
  #     before { bids(:one).awarded_at = Time.now }
  #     it { should be_awarded }
  #   end

  #   describe "award by officer" do
  #     it { should_not be_awarded }
  #     it "should correctly award by officer" do
  #       bids(:one).should_not_receive(:save)
  #       bids(:one).awarded_at.should be_nil
  #       bids(:one).award_by_officer(officers(:adam))
  #       bids(:one).awarded_at.should_not be_nil
  #       bids(:one).awarded_by_officer_id.should == officers(:adam).id
  #     end

  #     it "should save when using award_by_officer!" do
  #       bids(:one).should_receive(:save)
  #       bids(:one).award_by_officer!(officers(:adam))
  #     end
  #   end

  #   describe "unaward by officer" do
  #     before { bids(:one).award_by_officer!(officers(:adam)) }

  #     it "should correctly unaward by officer" do
  #       bids(:one).should_not_receive(:save)
  #       bids(:one).awarded_at.should_not be_nil
  #       bids(:one).unaward_by_officer(officers(:adam))
  #       bids(:one).awarded_at.should be_nil
  #       bids(:one).awarded_by_officer_id.should be_nil
  #     end

  #     it "should save when using unaward_by_officer!" do
  #       bids(:one).should_receive(:save)
  #       bids(:one).unaward_by_officer!(officers(:adam))
  #     end
  #   end
  # end

  # describe "validation" do
  #   pending
  # end
end
