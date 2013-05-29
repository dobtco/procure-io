# == Schema Information
#
# Table name: teams
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  organization_id  :integer
#  permission_level :integer          default(1)
#  user_count       :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe Team do
  before do
    @team = FactoryGirl.build(:team)
  end

  subject { @team }

  pending
end
