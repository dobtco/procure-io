# == Schema Information
#
# Table name: project_attachments
#
#  id         :integer          not null, primary key
#  project_id :integer
#  upload     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ProjectAttachment < ActiveRecord::Base
  belongs_to :project

  mount_uploader :upload, ProjectAttachmentUploader
end
