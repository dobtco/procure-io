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
  include SerializationHelper

  default_scope order('created_at')

  scope :unanswered, where("answer_body = '' OR answer_body IS NULL")

  belongs_to :project
  belongs_to :officer
  belongs_to :vendor

  after_create :generate_question_asked_events!

  after_update do
    generate_question_answered_events! if answer_body_changed? && answer_body && !answer_body.blank?
  end

  private
  def generate_question_asked_events!
    project.create_events(:question_asked,
                  project.watches.not_disabled.where_user_is_officer.pluck("users.id"),
                  vendor: serialized(vendor),
                  project: serialized(project, SimpleProjectSerializer))
  end

  handle_asynchronously :generate_question_asked_events!

  def generate_question_answered_events!
    project.create_events(:question_answered,
                  vendor.user.id,
                  officer: serialized(officer),
                  project: serialized(project, SimpleProjectSerializer))
  end

  handle_asynchronously :generate_question_answered_events!
end
