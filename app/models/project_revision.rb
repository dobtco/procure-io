# == Schema Information
#
# Table name: project_revisions
#
#  id                  :integer          not null, primary key
#  body                :text
#  project_id          :integer
#  saved_by_officer_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class ProjectRevision < ActiveRecord::Base
  belongs_to :project
  belongs_to :saved_by_officer, foreign_key: "saved_by_officer_id", class_name: "Officer"
  default_scope -> { includes(:saved_by_officer) }
end
