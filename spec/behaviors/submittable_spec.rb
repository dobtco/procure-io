require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/submittable'

class NoRailsTests::SubmittableModel < NoRailsTests::FakeModel
  include Behaviors::Submittable
end

describe Behaviors::Submittable do

  before { @model = NoRailsTests::SubmittableModel.new }

  describe '#submit' do
    it 'should return early if model is already submitted' do
      @model.submitted_at = Time.now
      @model.should_not_receive(:submitted_at=)
      @model.submit
    end

    it 'should set submitted_at' do
      @model.should_receive(:submitted_at=)
      @model.submit
    end

    it 'should call #after_submit if it exists' do
      @model.stub(:respond_to?).and_return(true)
      @model.should_receive(:after_submit)
      @model.submit
    end

    it 'should not call #after_submit if it does not exist' do
      @model.stub(:respond_to?).and_return(false)
      @model.should_not_receive(:after_submit)
      @model.submit
    end
  end

  describe '#submitted' do
    it 'should return true if submitted_at exists' do
      @model.submitted_at = Time.now
      @model.submitted.should == true
    end

    it 'should return false if submitted_at does not exist' do
      @model.submitted_at = nil
      @model.submitted.should == false
    end
  end

end
