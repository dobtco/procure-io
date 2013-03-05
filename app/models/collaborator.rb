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
    self.delay.create_collaborator_added_events!
    self.delay.create_you_were_added_events!
  end

  private
  def create_collaborator_added_events!
    event = project.events.create(event_type: Event.event_types[:collaborator_added],
                                  data: { officer: OfficerSerializer.new(officer, root: false),
                                          project: ProjectSerializer.new(project, root: false)}.to_json )

    project.watches.not_disabled.where(user_type: "Officer")
                                .where("user_id != ? AND user_id != ?", officer_id, added_by_officer_id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id, user_type: "Officer")
    end
  end

  def create_you_were_added_events!
    return if !officer.signed_up? || !added_by_officer_id

    event = project.events.create(event_type: Event.event_types[:you_were_added],
                                  data: { officer: OfficerSerializer.new(Officer.find(added_by_officer_id), root: false),
                                          project: ProjectSerializer.new(project, root: false)}.to_json )

    EventFeed.create(event_id: event.id, user_id: officer_id, user_type: "Officer")
  end
end
