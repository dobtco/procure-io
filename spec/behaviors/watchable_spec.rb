require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/watchable'
require 'active_support/all'

class NoRailsTests::WatchableModel < NoRailsTests::FakeModel
  include Behaviors::Watchable
end

describe Behaviors::Watchable do

  before { @model = NoRailsTests::WatchableModel.new }

  describe '#active_watchers' do
    before do
      @model.stub(:watches).and_return(@q = NoRailsTests::FakeQuery.new)
    end

    pending
  end

end
