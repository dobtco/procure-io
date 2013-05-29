# == Schema Information
#
# Table name: bids
#
#  id                               :integer          not null, primary key
#  vendor_id                        :integer
#  project_id                       :integer
#  submitted_at                     :datetime
#  dismissed_at                     :datetime
#  dismisser_id                     :integer
#  total_stars                      :integer          default(0)
#  total_comments                   :integer          default(0)
#  awarded_at                       :datetime
#  awarder_id                       :integer
#  average_rating                   :decimal(3, 2)
#  total_ratings                    :integer          default(0)
#  bidder_name                      :string(255)
#  dismissal_message                :text
#  show_dismissal_message_to_vendor :boolean          default(FALSE)
#  award_message                    :text
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'spec_helper'

describe Bid do
  before do
    @bid = FactoryGirl.build(:bid)
  end

  subject { @bid }

  describe 'Bid#add_params_to_query' do
    before { @query = NoRailsTests::FakeQuery.new }

    describe 'the status query parameter' do
      it 'should filter for dismissed' do
        @query.should_receive(:dismissed).and_return(@query)
        Bid.add_params_to_query(@query, status: 'dismissed')
      end

      it 'should filter for awarded' do
        @query.should_receive(:awarded).and_return(@query)
        Bid.add_params_to_query(@query, status: 'awarded')
      end

      it 'should default to filtering for open bids' do
        @query.should_receive(:where_open).and_return(@query)
        Bid.add_params_to_query(@query, {})
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
      Bid.should_receive(:searcher).with(hash_including(status: 'open'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(status: 'dismissed'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(status: 'awarded'), expected_new_hash)
      Bid.should_receive(:searcher).with(hash_including(label: 'bar'), expected_new_hash)

      Bid.search_meta_info({}, { simpler_query: 'Foo', project: mock(labels: [mock(id: 0, name: 'bar')]) })
    end
  end

  describe '#calculate_bidder_name' do
    it 'should return the name of the vendor if one exists' do
      @bid.should_receive(:vendor).at_least(:once).and_return(mock(display_name: 'Foo'))
      @bid.calculate_bidder_name.should == nil
    end

    it 'should next return the first_response' do
      @bid.should_receive(:vendor).at_least(:once).and_return(nil)
      @bid.should_receive(:first_response).at_least(:once).and_return(mock(display_value: "Foo"))
      @bid.calculate_bidder_name.should == 'Foo'
    end

    it 'should otherwise return an identification number' do
      @bid.should_receive(:id).at_least(:once).and_return(1)
      @bid.should_receive(:vendor).at_least(:once).and_return(nil)
      @bid.should_receive(:first_response).at_least(:once).and_return(nil)
      @bid.calculate_bidder_name.should == "#{I18n.t('g.vendor')} ##{@bid.id}"
    end
  end

  describe '#bid_review_for_user' do
    before do
      @user = FactoryGirl.create(:user)
      @bid.save
    end

    it "should find the user's bid review if it exists" do
      @bid_review = @user.bid_reviews.create(bid: @bid)
      @bid.bid_review_for_user(@user).should == @bid_review
    end

    it "should initialize a new review if it does not yet exist" do
      br = @bid.bid_review_for_user(@user)
      br.should be_new_record
      br.user_id.should == @user.id
    end
  end

end
