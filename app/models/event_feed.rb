# == Schema Information
#
# Table name: event_feeds
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  user_id    :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventFeed < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :unread, where(read: false)

  after_create :send_email

  def read!
    self.update_attributes(read: true)
  end

  def unread!
    self.update_attributes(read: false)
  end

  private
  def send_email
    return if user.class.name == "Officer" && !user.signed_up? # don't send an email to an officer if they're not signed up

    if user.send_email_notifications_for?(event.event_type)
      NotificationMailer.notification_email(user, event).deliver
    end
  end
end
