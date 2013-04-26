require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/watchable_by_user'
require 'active_support/all'

class Model < FakeModel
  include Behaviors::WatchableByUser
end

class FakeQuery
  def method_missing(meth, *args)
    self
  end
end

describe Behaviors::WatchableByUser do

  before { @model = Model.new }

  describe '#active_watchers' do
    before do
      @model.stub(:watches).and_return(@q = FakeQuery.new)
    end

    it 'should raise an exception if passed something other than :vendor or :officer' do
      expect {@model.active_watchers(:asdf)}.to raise_error(Exception)
    end

    it 'should properly search by vendor' do
      @q.should_receive(:where_user_is_vendor).and_return({})
      @model.active_watchers(:vendor)
    end

    it 'should properly search by officer' do
      @q.should_receive(:where_user_is_officer).and_return({})
      @model.active_watchers(:officer)
    end

    it 'should reject users in opts[:not_users]' do
      @q.should_receive(:where_user_is_vendor).and_return(@q)
      @q.should_receive(:where).with("users.id NOT IN (?)", [1, 3]).and_return({})
      @model.active_watchers(:vendor, not_users: [mock(id: 1), nil, mock(id: 3)])
    end

    it 'should return the user object' do
      @q.should_receive(:where_user_is_vendor).and_return([mock(user: "foo")])
      @model.active_watchers(:vendor).should == ["foo"]

    end
  end

end
