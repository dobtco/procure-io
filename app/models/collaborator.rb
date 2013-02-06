# == Schema Information
#
# Table name: collaborators
#
#  id         :integer          not null, primary key
#  project_id :integer
#  officer_id :integer
#  owner      :boolean
#

class Collaborator < ActiveRecord::Base
  attr_accessible :id, :project_id, :officer_id, :owner

  belongs_to :project
  belongs_to :officer
end
