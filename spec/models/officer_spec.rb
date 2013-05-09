# == Schema Information
#
# Table name: officers
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  title      :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Officer do

  let(:officer) { officers(:adam) }

  describe 'Officer#event_types' do
    it 'should not include event types for disabled features' do
      GlobalConfig.stub(:instance).and_return(OpenStruct.new)
      Event.stub(:event_types).and_return(event_types = Object.new)
      event_types.should_receive(:only).with(:collaborator_added, :you_were_added, :bulk_collaborators_added)
      Officer.event_types
    end

    it 'should include event types for enabled features' do
      GlobalConfig.stub(:instance).and_return(OpenStruct.new(questions_enabled: true))
      Event.stub(:event_types).and_return(event_types = Object.new)
      event_types.should_receive(:only).with(:collaborator_added, :you_were_added, :bulk_collaborators_added, :question_asked)
      Officer.event_types
    end
  end

  describe 'Officer#invite!' do
    it 'should create an officer with the default role' do
      Officer.should_receive(:create).with(role_id: roles(:admin).id).and_return(o = OpenStruct.new)
      User.should_receive(:create).and_return(OpenStruct.new)
      o.should_receive(:send_invitation_email!)
      Officer.invite!('foo@bar.com', projects(:one), nil)
    end

    it 'should allow the caller to specify a role' do
      Officer.should_receive(:create).with(role_id: 3).and_return(o = OpenStruct.new)
      User.should_receive(:create).and_return(OpenStruct.new)
      o.should_receive(:send_invitation_email!)
      Officer.invite!('foo@bar.com', projects(:one), 3)
    end
  end

  describe '#role_type' do
    it 'should return a symbol describing the officers role type' do
      officer.role_type.should == :admin
    end

    it 'should return :user if officer has no role' do
      officer.stub(:role).and_return(nil)
      officer.role_type.should == :user
    end
  end

  describe '#is_admin_or_god' do
    it 'should return true if admin or god' do
      officer.stub(:role_type).and_return(:admin)
      officer.is_admin_or_god.should == true
      officer.stub(:role_type).and_return(:god)
      officer.is_admin_or_god.should == true
    end

    it 'should return false otherwise' do
      officer.stub(:role_type).and_return(:user)
      officer.is_admin_or_god.should == false
      officer.stub(:role_type).and_return(:sdfasdff)
      officer.is_admin_or_god.should == false
    end
  end

  describe '#never_allowed_to' do
    it 'should only return true if user is not admin or god, and the permissions are set to never' do
      officer.stub(:is_admin_or_god).and_return(false)
      officer.stub(:role).and_return(OpenStruct.new(permissions: {"foo" => "never"}))
      officer.never_allowed_to("foo").should == true
    end

    it 'should return false otherwise' do
      officer.stub(:is_admin_or_god).and_return(true)
      officer.stub(:role).and_return(OpenStruct.new(permissions: {"foo" => "never"}))
      officer.never_allowed_to("foo").should == false
    end

    it 'should return false otherwise' do
      officer.stub(:is_admin_or_god).and_return(false)
      officer.stub(:role).and_return(OpenStruct.new(permissions: {"foo" => "sometimes"}))
      officer.never_allowed_to("foo").should == false
    end
  end

end
