# == Schema Information
#
# Table name: bids
#
#  id                               :integer          not null, primary key
#  vendor_id                        :integer
#  project_id                       :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  submitted_at                     :datetime
#  dismissed_at                     :datetime
#  dismissed_by_officer_id          :integer
#  total_stars                      :integer          default(0), not null
#  total_comments                   :integer          default(0), not null
#  awarded_at                       :datetime
#  awarded_by_officer_id            :integer
#  average_rating                   :decimal(3, 2)
#  total_ratings                    :integer
#  bidder_name                      :string(255)
#  dismissal_message                :text
#  show_dismissal_message_to_vendor :boolean          default(FALSE)
#

require 'spec_helper'

describe Bid do

  subject { bids(:one) }

  describe 'Bid#add_params_to_query' do
    before { @query = NoRailsTests::FakeQuery.new }

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

  describe '#calculate_bidder_name' do
    it 'should return the name of the vendor if one exists' do
      bids(:one).should_receive(:vendor).at_least(:once).and_return(mock(display_name: 'Foo'))
      bids(:one).calculate_bidder_name.should == nil
    end

    it 'should next return the key field responses' do
      bids(:one).should_receive(:vendor).at_least(:once).and_return(nil)
      bids(:one).should_receive(:project).at_least(:once).and_return(mock(key_fields: [mock(id: 1)]))
      bids(:one).should_receive(:key_field_responses).at_least(:once).and_return([mock(display_value: "Hi"), mock(display_value: "Bye")])
      bids(:one).calculate_bidder_name.should == 'Hi Bye'
    end

    it 'should otherwise return an identification number' do
      bids(:one).should_receive(:vendor).at_least(:once).and_return(nil)
      bids(:one).should_receive(:project).at_least(:once).and_return(mock(key_fields: []))
      bids(:one).calculate_bidder_name.should == "#{I18n.t('g.vendor')} ##{bids(:one).id}"
    end
  end

  describe '#bid_review_for_officer' do
    it "should find the officer's bid review if it exists" do
      bids(:one).bid_review_for_officer(officers(:adam)).should == bid_reviews(:one)
    end

    it "should initialize a new review if it does not yet exist" do
      bids(:one).bid_review_for_officer(officers(:clay)).should be_new_record
      bids(:one).bid_review_for_officer(officers(:clay)).officer_id.should == officers(:clay).id
    end
  end

end
