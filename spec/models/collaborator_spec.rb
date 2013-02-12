# == Schema Information
#
# Table name: collaborators
#
#  id         :integer          not null, primary key
#  project_id :integer
#  officer_id :integer
#  owner      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Collaborator do
  fixtures :all

  subject { collaborators(:adamone) }

  it { should respond_to(:owner) }

  it { should respond_to(:project) }
  it { should respond_to(:officer) }
end
