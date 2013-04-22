module EventsHelper
  def create_events(event_type, user_ids, data = {})
    event = events.create(event_type: Event.event_types[event_type],
                          data: data)

    Array(user_ids).each do |user_id|
      EventFeed.create(event_id: event.id, user_id: user_id)
    end
  end
end