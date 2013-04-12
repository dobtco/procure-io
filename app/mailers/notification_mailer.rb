class NotificationMailer < BaseMailer
  def notification_email(user, event)
    build_email user.email,
                'notification',
                event_text: event.text,
                event_additional_text: event.additional_text,
                name: user.display_name,
                event_url: URI.join(root_url, event.path)
  end
end
