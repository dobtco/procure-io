# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  email                    :string(255)
#  notification_preferences :text
#  created_at               :datetime
#  updated_at               :datetime
#  encrypted_password       :string(128)
#  confirmation_token       :string(128)
#  remember_token           :string(128)
#  completed_registration   :boolean          default(FALSE)
#  viewed_tours             :text
#  god                      :boolean          default(FALSE)
#

require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.build(:user)
  end

  subject { @user }

  describe '#is_vendor?' do
    it 'should calculate correctly' do
      @user.stub(:vendor_team_members).and_return([1])
      @user.is_vendor?.should == true
    end
  end

  describe '#is_officer?' do
    it 'should calculate correctly' do
      @user.stub(:organization_team_members).and_return([1])
      @user.is_officer?.should == true
    end
  end

  describe "#signed_up?" do
    it 'should be false for an invited user' do
      User.any_instance.stub(:send_invite_email!)
      u = User.invite!("foo@bar.com", @user)
      u.signed_up?.should == false
    end

    it 'should be true for a user with a password' do
      @user.signed_up?.should == true
    end
  end

  describe 'watching' do
    before do
      @user.save
      @project = FactoryGirl.create(:project)
      @user.watches.create(watchable: @project)
    end

    it 'should be true if there is a watch record' do
      @user.watches?(@project).should == true
    end

    it 'should be false if there is no watch record' do
      @user.watches?(FactoryGirl.create(:project)).should == false
    end

    it 'should unwatch the watchable object' do
      @user.watches?(@project).should == true
      @user.unwatch!(@project)
      @user.watches?(@project).should == false
    end

    it 'should watch the watchable object' do
      @project_two = FactoryGirl.create(:project)
      @user.watch!(@project_two)
      @user.watches?(@project_two).should == true
    end
  end

  describe '#send_reset_password_instructions!' do
    it 'should send an email' do
      Mailer.should_receive(:password_reset_email).with(@user).and_return(OpenStruct.new)
      @user.send_reset_password_instructions!
    end
  end

  describe '#receives_event?' do
    pending
  end

  describe '#set_default_notification_preferences' do
    it 'should set preferences to :on_with_email' do
      @user.save
      @user.notification_preferences.values[0].should == User.notification_preference_values[:on_with_email]
    end
  end

  describe '#read_notifications' do
    before do
      @user.stub(:send_email_notifications_for?).and_return(false)
      @project = FactoryGirl.create(:project)
      @event = Event.create(targetable: @project, event_type: Event.event_types[:project_comment])
      @event_feed = EventFeed.create(event: @event, user: @user)
    end

    it 'should read notifications by event type' do
      @user.unread_notification_count.should == 1
      @user.read_notifications(@project, :project_comment)
      @user.unread_notification_count.should == 0
    end

    it 'should not read notifications if they do not match the event type' do
      @user.unread_notification_count.should == 1
      @user.read_notifications(@project, :bid_comment)
      @user.unread_notification_count.should == 1
    end

    it 'should read all notifications if not passed an event type' do
      @user.unread_notification_count.should == 1
      @user.read_notifications(@project)
      @user.unread_notification_count.should == 0
    end
  end
end
