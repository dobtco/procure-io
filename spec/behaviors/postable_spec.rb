require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/postable'

class NoRailsTests::PostableModel < NoRailsTests::FakeModel
  include Behaviors::Postable
end

describe Behaviors::Postable do

  before { @model = NoRailsTests::PostableModel.new }

  describe '#posted' do
    it 'should return true or false based on posted_at' do
      @model.posted_at = Time.now
      @model.posted.should == true
      @model.posted_at = nil
      @model.posted.should == false
    end
  end

  describe '#post' do
    it 'should set posted_at and poster_id' do
      @model.post(stub(id: 1))
      @model.posted_at.to_i.should == Time.now.to_i
      @model.poster_id.should == 1
    end
  end

  describe '#unpost' do
    it 'should remove posted_at and poster_id' do
      @model.posted_at = Time.now
      @model.poster_id = 1
      @model.unpost(stub(id: 1))
      @model.posted_at.should be_nil
      @model.poster_id.should be_nil
    end
  end

end
