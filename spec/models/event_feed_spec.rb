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

require 'spec_helper'

describe EventFeed do
  describe '#send_email' do
    it 'should send the proper notification email' do
      e = EventFeed.new(user: users(:adam_user))
      e.stub(:event).and_return(OpenStruct.new)
      users(:adam_user).stub(:send_email_notifications_for?).and_return(true)
      Mailer.should_receive(:notification_email).and_return(OpenStruct.new)
      e.send(:send_email)
    end

    it 'should return early if the user is not signed up' do
      e = EventFeed.new(user: users(:adam_user))
      users(:adam_user).stub(:signed_up?).and_return(false)
      Mailer.should_not_receive(:notification_email)
      e.send(:send_email)
    end

    it 'should return early if the user does not receive email notifications for this event type' do
      e = EventFeed.new(user: users(:adam_user))
      e.stub(:event).and_return(OpenStruct.new)
      users(:adam_user).stub(:send_email_notifications_for?).and_return(false)
      Mailer.should_not_receive(:notification_email)
      e.send(:send_email)
    end
  end
end
