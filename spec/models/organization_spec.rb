# == Schema Information
#
# Table name: organizations
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  username    :string(255)
#  logo        :string(255)
#  event_hooks :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Organization do
  before do
    @organization = FactoryGirl.build(:organization)
  end

  subject { @organization }

  pending
end
