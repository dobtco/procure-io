# == Schema Information
#
# Table name: project_revisions
#
#  id                  :integer          not null, primary key
#  body                :text
#  project_id          :integer
#  saved_by_officer_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'spec_helper'

describe ProjectRevision do
end
