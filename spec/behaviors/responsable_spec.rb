require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/responsable'

class NoRailsTests::ResponsableModel < NoRailsTests::FakeModel
  include Behaviors::Responsable
end

describe Behaviors::Responsable do

  before { @model = NoRailsTests::ResponsableModel.new }

  describe '#responsable_valid?' do
    it 'should return true if there are no errors' do
      @model.stub(:responsable_errors).and_return([])
      @model.responsable_valid?.should == true
    end

    it 'should return false if there are errors' do
      @model.stub(:responsable_errors).and_return("error")
      @model.responsable_valid?.should == false
    end
  end

end
