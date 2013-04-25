module Behaviors
  module TargetableForEvents
    include SerializationHelper

    def self.included(base)
      base.has_many :events, as: :targetable
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def create_events(event_type, users, *objects)
      data = build_serialized_data_for_objects(objects)

      event = self.events.create(event_type: Event.event_types[event_type], data: data)

      Array(users).each do |user|
        EventFeed.create(event_id: event.id, user_id: user.id) if user.can_receive_event(event)
      end
    end

    private
    def build_serialized_data_for_objects(objects)
      data = {}

      # Allow user to pass the already-serialized hash, which we'll just let pass through.
      return objects[0] if objects[0].is_a?(Hash)

      objects.each do |object|
        serializer = object.class == Project ? SimpleProjectSerializer : nil
        data[object.class.name.downcase.to_sym] = serialized(object, serializer)
      end

      data
    end
  end
end
