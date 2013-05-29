# == Schema Information
#
# Table name: vendor_team_members
#
#  id         :integer          not null, primary key
#  vendor_id  :integer
#  user_id    :integer
#  owner      :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe VendorTeamMember do
  pending
end
