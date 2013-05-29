# == Schema Information
#
# Table name: project_revisions
#
#  id               :integer          not null, primary key
#  body             :text
#  project_id       :integer
#  saved_by_user_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe ProjectRevision do
  pending
end
