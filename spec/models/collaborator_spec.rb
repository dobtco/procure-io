# == Schema Information
#
# Table name: collaborators
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  officer_id          :integer
#  owner               :boolean
#  created_at          :datetime
#  updated_at          :datetime
#  added_by_officer_id :integer
#  added_in_bulk       :boolean
#

require 'spec_helper'

describe Collaborator do

  let (:collaborator) { collaborators(:adamone) }

  describe 'after create' do
    it 'should automatically watch the project and create the correct events' do
      c = Collaborator.new(officer: officers(:clay), project: projects(:one))
      officers(:clay).user.should_receive(:watch!)
      c.should_receive(:create_collaborator_added_events!)
      c.should_receive(:create_you_were_added_events!)
      c.save
    end
  end

  describe 'before destroy' do
    it 'should destroy all watches for a user' do
      collaborator.officer.user.watches?(collaborator.project).should == true
      collaborator.officer.user.watches?(bids(:one)).should == true
      collaborator.destroy
      collaborator.officer.user.watches?(collaborator.project).should == false
      collaborator.officer.user.watches?(bids(:one)).should == false
    end
  end

  describe 'Collaborator#send_added_in_bulk_events' do
    it 'should create the proper event' do
      projects(:one).should_receive(:create_events).with(:bulk_collaborators_added, anything(), anything())
      Collaborator.send_added_in_bulk_events!([], projects(:one), users(:adam_user))
    end
  end

  describe '#create_collaborator_added_events' do
    it 'should create the proper event' do
      collaborator.project.should_receive(:create_events).with(:collaborator_added, anything(), anything(), anything())
      collaborator.send(:create_collaborator_added_events!)
    end

    it 'should return early if collaborator was added in bulk' do
      collaborator.added_in_bulk = true
      collaborator.project.should_not_receive(:create_events)
      collaborator.send(:create_collaborator_added_events!)
    end
  end

  describe '#create_you_were_added_events' do
    it 'should create the proper event' do
      collaborator.added_by_officer_id = 1
      collaborator.project.should_receive(:create_events).with(:you_were_added, anything(), anything(), anything())
      collaborator.send(:create_you_were_added_events!)
    end

    it 'should return early if added_by_officer_id is nil' do
      collaborator.added_by_officer_id = nil
      collaborator.project.should_not_receive(:create_events)
      collaborator.send(:create_you_were_added_events!)
    end

    it 'should return early if collaborator is not yet signed up' do
      collaborator.officer.stub(:user).and_return(mock("User", signed_up?: false))
      collaborator.project.should_not_receive(:create_events)
      collaborator.send(:create_you_were_added_events!)
    end
  end
end
