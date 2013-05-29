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

class OrganizationTeamMember < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  belongs_to :added_by_user, class_name: "User"

  after_create :complete_user_registration!, :calculate_team_user_count!, :send_events!

  private
  def send_events!
    return unless added_by_user
    team.organization.create_events(:added_to_organization_team, user, team.organization, team)
  end

  handle_asynchronously :send_events!

  def calculate_team_user_count!
    team.calculate_user_count!
  end

  def complete_user_registration!
    user.update_attributes(completed_registration: true)
  end
end
