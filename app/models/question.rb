# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  asker_id    :integer
#  answerer_id :integer
#  body        :text
#  answer_body :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Question < ActiveRecord::Base
  default_scope -> { order('created_at') }

  scope :unanswered, -> { where("answer_body = '' OR answer_body IS NULL") }

  belongs_to :project
  belongs_to :asker, class_name: "User"
  belongs_to :answerer, class_name: "User"

  after_create :generate_question_asked_events!

  after_update do
    generate_question_answered_events! if answer_body_changed? && !answer_body.blank?
  end

  private
  def generate_question_asked_events!
    project.create_events(:question_asked,
                          project.active_watchers(user_can: :collaborate_on),
                          asker,
                          project)
  end

  handle_asynchronously :generate_question_asked_events!

  def generate_question_answered_events!
    project.create_events(:question_answered,
                          asker,
                          answerer,
                          project)

  end

  handle_asynchronously :generate_question_answered_events!
end
