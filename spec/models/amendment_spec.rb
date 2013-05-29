# == Schema Information
#
# Table name: amendments
#
#  id         :integer          not null, primary key
#  project_id :integer
#  body       :text
#  posted_at  :datetime
#  poster_id  :integer
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Amendment do
  before do
    @amendment = FactoryGirl.build(:amendment)
  end

  subject { @amendment }

  it 'should create an event when posted' do
    @amendment.should_receive(:after_post)
    @amendment.post(FactoryGirl.build(:user))
    @amendment.save
  end
end
