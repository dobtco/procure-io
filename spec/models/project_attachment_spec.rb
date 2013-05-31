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

require 'spec_helper'

describe ProjectAttachment do
  pending "add some examples to (or delete) #{__FILE__}"
end
