# == Schema Information
#
# Table name: amendments
#
#  id                   :integer          not null, primary key
#  project_id           :integer
#  body                 :text
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  title                :text
#

class Amendment < ActiveRecord::Base
  include PostableByOfficer

  belongs_to :project, touch: true

  private
  def after_post_by_officer(officer)
    create_vendor_notifications!
  end

  def create_vendor_notifications!
    event = project.events.create(event_type: Event.event_types[:project_amended], data: ProjectSerializer.new(project, root: false).to_json)

    project.watches.not_disabled.where_user_is_vendor.each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end

  handle_asynchronously :create_vendor_notifications!
end
