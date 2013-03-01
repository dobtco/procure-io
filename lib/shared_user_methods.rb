module SharedUserMethods
  def gravatar_url
    "//gravatar.com/avatar/#{Digest::MD5::hexdigest(email.downcase)}?size=45&d=identicon"
  end

  def display_name
    self.name || self.email
  end

  # @todo use update_all for performance?
  def read_notifications(targetable, event_type = nil)
    targetable.events.where(event_type: event_type).include_users_event_feed(self).each do |event|
      event.users_event_feed.read!
    end
  end
end