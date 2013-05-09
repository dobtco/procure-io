# == Schema Information
#
# Table name: amendments
#
#  id                   :integer          not null, primary key
#  project_id           :integer
#  body                 :text
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#  title                :text
#

require 'spec_helper'

describe Amendment do
  subject { amendments(:one) }

  it 'should create an event when posted' do
    amendments(:one).project.should_receive(:create_events)
    amendments(:one).posted_at = nil
    amendments(:one).post_by_officer(officers(:adam))
  end
end
