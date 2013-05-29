# == Schema Information
#
# Table name: event_feeds
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  user_id    :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class EventFeed < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :unread, -> { where(read: false) }

  after_create :send_email

  def read!
    update_attributes(read: true)
  end

  def unread!
    update_attributes(read: false)
  end

  private
  def send_email
    # don't send an email to a user if they're not signed up or their preferences are set
    # to not receive these types of emails
    return if !user.signed_up? || !user.send_email_notifications_for?(event)
    Mailer.notification_email(user, event).deliver
  end
end
