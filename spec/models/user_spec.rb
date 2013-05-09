# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  notification_preferences :text
#  owner_id                 :integer
#  owner_type               :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  perishable_token         :string(255)      default(""), not null
#  last_login_at            :datetime
#  current_login_at         :datetime
#  last_login_ip            :string(255)
#  current_login_ip         :string(255)
#

require 'spec_helper'

describe User do
  let(:user) { users(:adam_user) }

  describe '#is_vendor?' do
    it 'should calculate correctly' do
      officers(:adam).user.is_vendor?.should == false
      vendors(:one).user.is_vendor?.should == true
    end
  end

  describe '#is_officer?' do
    it 'should calculate correctly' do
      officers(:adam).user.is_officer?.should == true
      vendors(:one).user.is_officer?.should == false
    end
  end

  describe 'User#find_for_invite_or_password_reset_token' do
    it 'should find invited users without an expiration' do
      user.reset_perishable_token!
      user.update_attributes(updated_at: Time.now - 4.days, crypted_password: nil, current_login_at: nil, last_login_at: nil)
      User.find_for_invite_or_password_reset_token(user.perishable_token).should == user
    end

    it 'should only find users by password reset token if it was generated in the last 3 days' do
      user.reset_perishable_token!
      User.find_for_invite_or_password_reset_token(user.perishable_token).should == user
    end

    it 'should not find users by password reset token if it wasnt generated in the last 3 days' do
      user.reset_perishable_token!
      user.update_attributes(updated_at: Time.now - 4.days)
      User.find_for_invite_or_password_reset_token(user.perishable_token).should == nil
    end
  end

  describe "#signed_up?" do
    it 'should be false for an invited user' do
      u = User.new(email: "foo@bar.com")
      u.signed_up?.should == false
    end

    it 'should be true for a user with a password' do
      u = User.new(email: "foo@bar.com", password: "password")
      u.signed_up?.should == true
    end

    it 'should be true for a user with no password that has logged in before' do
      u = User.new(email: "foo@bar.com", current_login_at: Time.now)
      u.signed_up?.should == true
    end
  end

  describe '#watches?' do
    it 'should be true if there is a watch record' do
      user.watches?(projects(:one)).should == true
    end

    it 'should be false if there is no watch record' do
      user.watches?(projects(:two)).should == false
    end
  end

  describe '#unwatch!' do
    it 'should unwatch the watchable object' do
      user.watches?(projects(:one)).should == true
      user.unwatch!(projects(:one))
      user.watches?(projects(:one)).should == false
    end
  end

  describe '#watch!' do
    it 'should watch the watchable object' do
      user.watch!(projects(:two))
      user.watches?(projects(:two)).should == true
    end
  end

  describe '#send_reset_password_instructions!' do
    it 'should send an email' do
      Mailer.should_receive(:password_reset_email).with(user).and_return(OpenStruct.new)
      user.send_reset_password_instructions!
    end
  end

  describe '#can_receive_event' do
    it 'should return true for a vendor, regardless of event type' do
      users(:vendor_user).can_receive_event("foo").should == true
      users(:vendor_user).can_receive_event(:bid_comment).should == true
    end

    it 'should calculate true for officers' do
      event = OpenStruct.new(event_type: Event.event_types[:project_comment])
      ability = mock("Ability")
      ability.should_receive(:can?).and_return(true)
      Ability.should_receive(:new).and_return(ability)
      user.can_receive_event(event).should == true
    end

    it 'should calculate false for officers' do
      event = OpenStruct.new(event_type: Event.event_types[:project_comment])
      ability = mock("Ability")
      ability.should_receive(:can?).and_return(false)
      Ability.should_receive(:new).and_return(ability)
      user.can_receive_event(event).should == false
    end
  end

  describe '#set_default_notification_preferences' do
    it 'should be called before create' do
      u = User.new(email: "bar@baz.com")
      u.stub(:owner).and_return(OpenStruct.new(default_notification_preferences: "foo"))
      u.should_receive(:notification_preferences=).with("foo")
      u.save
    end
  end

  describe '#read_notifications' do
    before do
      @event = Event.create(targetable: projects(:one), event_type: Event.event_types[:project_comment])
      @event_feed = EventFeed.create(event: @event, user: user)
    end

    it 'should read notifications by event type' do
      user.unread_notification_count.should == 1
      user.read_notifications(projects(:one), :project_comment)
      user.unread_notification_count.should == 0
    end

    it 'should not read notifications if they do not match the event type' do
      user.unread_notification_count.should == 1
      user.read_notifications(projects(:one), :bid_comment)
      user.unread_notification_count.should == 1
    end

    it 'should read all notifications if not passed an event type' do
      user.unread_notification_count.should == 1
      user.read_notifications(projects(:one))
      user.unread_notification_count.should == 0
    end
  end
end
