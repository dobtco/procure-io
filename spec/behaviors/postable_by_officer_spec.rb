require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/postable_by_officer'

class NoRailsTests::PostableByOfficerModel < NoRailsTests::FakeModel
  include Behaviors::PostableByOfficer
end

describe Behaviors::PostableByOfficer do

  before { @model = NoRailsTests::PostableByOfficerModel.new }

  describe '#posted' do
    it 'should return true or false based on posted_at' do
      @model.posted_at = Time.now
      @model.posted.should == true
      @model.posted_at = nil
      @model.posted.should == false
    end
  end

  describe '#post_by_officer' do
    it 'should set posted_at and posted_by_officer_id' do
      @model.post_by_officer(stub(id: 1))
      @model.posted_at.to_i.should == Time.now.to_i
      @model.posted_by_officer_id.should == 1
    end
  end

  describe '#unpost_by_officer' do
    it 'should remove posted_at and posted_by_officer_id' do
      @model.posted_at = Time.now
      @model.posted_by_officer_id = 1
      @model.unpost_by_officer(stub(id: 1))
      @model.posted_at.should be_nil
      @model.posted_by_officer_id.should be_nil
    end
  end

end
