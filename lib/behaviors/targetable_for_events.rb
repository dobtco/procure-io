module Behaviors
  module TargetableForEvents
    def self.included(base)
      base.has_many :events, as: :targetable, dependent: :destroy
      base.extend(ClassMethods)
      base.send(:include, SerializationHelper)
    end

    module ClassMethods
    end

    def create_events(event_type, users, *objects)
      data = build_serialized_data_for_objects(objects)

      event = self.events.create(event_type: Event.event_types[event_type], data: data)

      Array(users).each do |user|
        EventFeed.create(event_id: event.id, user_id: user.id) if user.receives_event?(event)
      end
    end

    private
    def build_serialized_data_for_objects(objects)
      data = {}

      # Allow user to pass the already-serialized hash, which we'll just let pass through.
      return objects[0] if objects[0].is_a?(Hash)

      objects.each do |object|
        data[object.class.name.downcase.to_sym] = serialized(object)
      end

      data
    end
  end
end
