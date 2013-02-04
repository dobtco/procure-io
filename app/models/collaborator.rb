# == Schema Information
#
# Table name: collaborators
#
#  project_id :integer
#  officer_id :integer
#  owner      :boolean
#

class Collaborator < ActiveRecord::Base
  attr_accessible :owner

  belongs_to :project
  belongs_to :officer
end
