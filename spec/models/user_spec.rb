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
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
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
end
