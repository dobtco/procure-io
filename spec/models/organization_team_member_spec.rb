# == Schema Information
#
# Table name: organization_team_members
#
#  id               :integer          not null, primary key
#  team_id          :integer
#  user_id          :integer
#  added_by_user_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe OrganizationTeamMember do
  pending
end
