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

class Collaborator < ActiveRecord::Base
  belongs_to :project
  belongs_to :officer
  belongs_to :added_by_officer, class_name: "Officer"

  after_create do
    officer.user.watch!(project)
    self.delay.create_collaborator_added_events!
    self.delay.create_you_were_added_events!
  end

  before_destroy do
    officer.user.watches.for(project).destroy_all
    officer.user.watches.for(:bid, project.bids.pluck(:id)).destroy_all
  end

  def self.send_added_in_bulk_events!(users, project, current_user)
    project.create_events(:bulk_collaborators_added,
                          project.active_watchers(:officer, not_users: [current_user, *users]),
                          names: users.map {|u| u.owner.display_name}.join(', '),
                          count: users.count,
                          project: SimpleProjectSerializer.new(project, root: false))
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

    project.create_events(:you_were_added,
                          officer.user,
                          officer,
                          project)

  end
end
