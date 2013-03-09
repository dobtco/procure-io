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
end
