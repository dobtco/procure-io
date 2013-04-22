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
  include SerializationHelper

  belongs_to :project
  belongs_to :officer

  after_create do
    officer.user.watch!("Project", project_id)
    self.delay.create_collaborator_added_events!
    self.delay.create_you_were_added_events!
  end

  before_destroy do
    officer.user.watches.where(watchable_type: "Project", watchable_id: project_id).destroy_all
    officer.user.watches.where(watchable_type: "Bid").where("watchable_id IN (?)", project.bids.pluck(:id)).destroy_all
  end

  def self.send_added_in_bulk_events!(users, project, current_user_id)
    not_ids = [current_user_id] + users.map(&:id)

    project.create_events(:bulk_collaborators_added,
                  project.watches.where_user_is_officer.not_disabled.where("user_id NOT IN (?)", not_ids).pluck("users.id"),
                  names: users.map(&:display_name).join(', '),
                  count: users.count,
                  project: serialized(project, SimpleProjectSerializer))
  end

  private
  def create_collaborator_added_events!
    return if added_in_bulk # don't send multiple emails when bulk-adding collaborators

    not_ids = [officer.user.id]
    not_ids.push(Officer.find(added_by_officer_id).user.id) if added_by_officer_id

    project.create_events(:collaborator_added,
                  project.watches.where_user_is_officer.not_disabled.where("user_id NOT IN (?)", not_ids).pluck("users.id"),
                  officer: serialized(officer),
                  project: serialized(project, SimpleProjectSerializer))
  end

  def create_you_were_added_events!
    return if !added_by_officer_id
    return if !officer.user.signed_up?

    project.create_events(:you_were_added,
                  officer.user.id,
                  officer: serialized(officer),
                  project: serialized(project, SimpleProjectSerializer))
  end
end
