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

require 'spec_helper'

describe EventFeed do
  before do
    @user = FactoryGirl.create(:user)
    @event_feed = FactoryGirl.build(:event_feed, user: @user)
  end

  subject { @event_feed }

  describe '#send_email' do
    it 'should send the proper notification email' do
      @event_feed.stub(:event).and_return(OpenStruct.new)
      @user.stub(:send_email_notifications_for?).and_return(true)
      Mailer.should_receive(:notification_email).and_return(OpenStruct.new)
      @event_feed.send(:send_email)
    end

    it 'should return early if the user is not signed up' do
      @event_feed.stub(:event).and_return(OpenStruct.new)
      @user.stub(:send_email_notifications_for?).and_return(true)
      @user.stub(:signed_up?).and_return(false)
      Mailer.should_not_receive(:notification_email)
      @event_feed.send(:send_email)
    end

    it 'should return early if the user does not receive email notifications for this event type' do
      @event_feed.stub(:event).and_return(OpenStruct.new)
      @user.stub(:send_email_notifications_for?).and_return(false)
      Mailer.should_not_receive(:notification_email)
      @event_feed.send(:send_email)
    end
  end
end
