require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/targetable_for_events'

module SerializationHelper
end

class Event
end

class EventFeed
end

class Project
end

class Bid
end

class Model < FakeModel
  include Behaviors::TargetableForEvents
end

class SimpleProjectSerializer
end

describe Behaviors::TargetableForEvents do

  before { @model = Model.new }

  describe '#create_events' do
    it 'should create the proper event' do
      @model.stub(:build_serialized_data_for_objects).and_return("data!")
      events = OpenStruct.new
      @model.stub(:events).and_return(events)
      Event.should_receive(:event_types).and_return(["bar"])
      events.should_receive(:create).with(event_type: "bar", data: "data!")
      @model.create_events(0, [], "boo")
    end

    it 'should create an entry in each users event feed' do
      events = OpenStruct.new
      events.should_receive(:create).and_return(event = OpenStruct.new(id: 9))
      user = OpenStruct.new(id: 8)
      @model.stub(:build_serialized_data_for_objects).and_return("data!")
      @model.stub(:events).and_return(events)
      Event.should_receive(:event_types).and_return(["bar"])
      user.should_receive(:can_receive_event).and_return(true)
      EventFeed.should_receive(:create).with(event_id: 9, user_id: 8)
      @model.create_events(0, [user], "boo")
    end
  end

  describe '#build_serialized_data_for_objects' do
    it 'should let a hash pass-through unchanged' do
      @model.send(:build_serialized_data_for_objects, [foo: 'bar']).should == {foo: 'bar'}
    end

    it 'should serialize each object' do
      obj1 = Project.new
      obj2 = Bid.new
      @model.should_receive(:serialized).with(obj1, SimpleProjectSerializer)
      @model.should_receive(:serialized).with(obj2, nil)
      @model.send(:build_serialized_data_for_objects, [obj1, obj2])
    end
  end

end
