# == Schema Information
#
# Table name: collaborators
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  officer_id          :integer
#  owner               :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  added_by_officer_id :integer
#  added_in_bulk       :boolean
#

require 'spec_helper'

describe Collaborator do
  subject { collaborators(:adamone) }

  it { should respond_to(:owner) }

  it { should respond_to(:project) }
  it { should respond_to(:officer) }
end
