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
#

class Collaborator < ActiveRecord::Base
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

  private
  def create_collaborator_added_events!
    event = project.events.create(event_type: Event.event_types[:collaborator_added],
                                  data: { officer: OfficerSerializer.new(officer, root: false),
                                          project: ProjectSerializer.new(project, root: false)}.to_json )

    not_ids = [officer.user.id]
    not_ids.push(Officer.find(added_by_officer_id).user.id) if added_by_officer_id

    project.watches.not_disabled.where("user_id NOT IN (?)", not_ids).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end

  def create_you_were_added_events!
    return if !added_by_officer_id

    event = project.events.create(event_type: Event.event_types[:you_were_added],
                                  data: { officer: OfficerSerializer.new(Officer.find(added_by_officer_id), root: false),
                                          project: ProjectSerializer.new(project, root: false)}.to_json )

    EventFeed.create(event_id: event.id, user_id: officer.user.id)
  end
end
