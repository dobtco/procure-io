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

class VendorTeamMember < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :user

  after_create :send_events!, :complete_user_registration!

  private
  def send_events!
    return if owner # don't send an event when we create the vendor
    vendor.create_events(:added_to_vendor_team, user, vendor)
  end

  handle_asynchronously :send_events!

  def complete_user_registration!
    user.update_attributes(completed_registration: true)
  end
end
