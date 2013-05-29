require_relative '../support/no_rails_tests'
require_relative '../../lib/calculator'

class NoRailsTests::CalculatorModel < NoRailsTests::FakeModel
  include Calculator
end

describe Calculator do

  before { @model = NoRailsTests::CalculatorModel.new }

  describe '#calculator' do
    it 'should define #calculate_name' do
      NoRailsTests::CalculatorModel.calculator :foo do "bar" end
      @model.should respond_to(:calculate_foo)
    end

    it 'should calculate the result and set the property' do
      NoRailsTests::CalculatorModel.calculator :foo do "bar" end
      @model.should_receive(:foo=).with("bar")
      @model.calculate_foo
    end

    it 'should count the results if necessary' do
      NoRailsTests::CalculatorModel.calculator :foo do ["a", "b", "c"] end
      @model.should_receive(:foo=).with(3)
      @model.calculate_foo
    end

    it 'should create a dangerous alias' do
      NoRailsTests::CalculatorModel.should_receive(:dangerous_alias)
      NoRailsTests::CalculatorModel.calculator :foo do "bar" end
    end
  end

end
