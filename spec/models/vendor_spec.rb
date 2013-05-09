# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Vendor do

  subject { vendors(:one) }

  describe 'Vendor#add_params_to_query' do
    before { @query = NoRailsTests::FakeQuery.new }

    describe 'the sort parameter' do
      it 'should sort by response field when it is a number' do
        @query.should_receive(:join_response_for_response_field_id).and_return(@query)
        ResponseField.stub(:find).and_return(mock(field_type: "foo"))
        Vendor.add_params_to_query(@query, sort: "3")
      end

      it 'should not sort by response field when it is not a number' do
        @query.should_not_receive(:join_response_for_response_field_id)
        Vendor.add_params_to_query(@query, sort: "asdf")
      end
    end


    describe 'the q parameter' do
      it 'should perform a full search' do
        @query.should_receive(:full_search).with('Foo').and_return(@query)
        Vendor.add_params_to_query(@query, q: 'Foo')
      end

      it 'should not search if blank' do
        @query.should_not_receive(:full_search)
        Vendor.add_params_to_query(@query, q: '')
      end
    end
  end

  describe "bid for project" do
    it "should return the correct bid" do
      vendors(:one).bid_for_project(projects(:one)).should == bids(:one)
    end
  end

  describe "submitted bid for project" do
    it "should return the correct bid" do
      vendors(:one).submitted_bid_for_project(projects(:one)).should == bids(:one)
    end

    it "should return nil when not submitted" do
      bids(:one).update_attributes(submitted_at: nil)
      vendors(:one).submitted_bid_for_project(projects(:one)).should == nil
    end
  end

end
