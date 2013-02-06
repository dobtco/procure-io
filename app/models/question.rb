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
  # @todo scopes for these, or use new rails 4 way of doing things
  attr_accessible :answer_body, :officer_id, :vendor_id, :body, :project_id

  default_scope order('created_at')

  belongs_to :project
  belongs_to :officer
  belongs_to :vendor
end
