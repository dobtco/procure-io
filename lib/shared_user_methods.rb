module SharedUserMethods
  def gravatar_url
    "//gravatar.com/avatar/#{Digest::MD5::hexdigest(email.downcase)}?size=45&d=identicon"
  end

  def display_name
    self.name || self.email
  end

  # @todo use update_all for performance?
  def read_notifications(targetable, *event_types)
    sql = targetable.events

    if event_types.any?
      sql = sql.where("event_type IN (?)", event_types)
    end

    sql.include_users_event_feed(self).each do |event|
      event.users_event_feed.read!
    end
  end

  def unread_notification_count
    self.event_feeds.unread.count
  end
end