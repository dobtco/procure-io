# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  vendor_id   :integer
#  officer_id  :integer
#  body        :text
#  answer_body :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Question < ActiveRecord::Base
  default_scope order('created_at')

  scope :unanswered, where("answer_body = '' OR answer_body IS NULL")

  belongs_to :project
  belongs_to :officer
  belongs_to :vendor

  after_create :generate_question_asked_events!

  # @todo vendor will see multiple events if the officer progressively saves their answer
  after_update do
    generate_question_answered_events! if answer_body_changed? && answer_body && !answer_body.blank?
  end

  private
  def generate_question_asked_events!
    event = project.events.create(event_type: Event.event_types[:question_asked],
                                  data: { vendor: VendorSerializer.new(vendor, root: false),
                                          project: ProjectSerializer.new(project, root: false) }.to_json )

    project.watches.not_disabled.where_user_is_officer.each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end

  handle_asynchronously :generate_question_asked_events!

  def generate_question_answered_events!
    event = project.events.create(event_type: Event.event_types[:question_answered],
                                  data: { officer: OfficerSerializer.new(officer, root: false),
                                          project: ProjectSerializer.new(project, root: false) }.to_json )

    vendor.user.event_feeds.create(event_id: event.id)
  end

  handle_asynchronously :generate_question_answered_events!
end
