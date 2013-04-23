# == Schema Information
#
# Table name: collaborators
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  officer_id          :integer
#  owner               :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  added_by_officer_id :integer
#  added_in_bulk       :boolean
#

class Collaborator < ActiveRecord::Base
  belongs_to :project
  belongs_to :officer
  belongs_to :added_by_officer, class_name: "Officer"

  after_create do
    officer.user.watch!("Project", project_id)
    self.delay.create_collaborator_added_events!
    self.delay.create_you_were_added_events!
  end

  before_destroy do
    officer.user.watches.where(watchable_type: "Project", watchable_id: project_id).destroy_all
    officer.user.watches.where(watchable_type: "Bid").where("watchable_id IN (?)", project.bids.pluck(:id)).destroy_all
  end

  private
  def create_collaborator_added_events!
    return if added_in_bulk # don't send multiple emails when bulk-adding collaborators

    project.create_events(:collaborator_added,
                          project.active_watchers(:officer, not_users: [officer.user, added_by_officer]),
                          officer,
                          project)

  end

  def create_you_were_added_events!
    return if !added_by_officer_id
    return if !officer.user.signed_up?

    project.create_events(:collaborator_added,
                          officer.user,
                          officer,
                          project)

  end
end
