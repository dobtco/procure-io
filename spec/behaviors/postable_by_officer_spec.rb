require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/postable_by_officer'

class Postable < FakeModel
  include Behaviors::PostableByOfficer
end

describe Behaviors::PostableByOfficer do

  before { @postable = Postable.new }

  describe '#posted' do
    it 'should return true or false based on posted_at' do
      @postable.posted_at = Time.now
      @postable.posted.should == true
      @postable.posted_at = nil
      @postable.posted.should == false
    end
  end


  describe '#post_by_officer' do
    it 'should set posted_at and posted_by_officer_id' do
      @postable.post_by_officer(stub(id: 1))
      @postable.posted_at.to_i.should == Time.now.to_i
      @postable.posted_by_officer_id.should == 1
    end
  end

  describe '#unpost_by_officer' do
    it 'should remove posted_at and posted_by_officer_id' do
      @postable.posted_at = Time.now
      @postable.posted_by_officer_id = 1
      @postable.unpost_by_officer(stub(id: 1))
      @postable.posted_at.should be_nil
      @postable.posted_by_officer_id.should be_nil
    end
  end

end