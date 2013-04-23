# == Schema Information
#
# Table name: amendments
#
#  id                   :integer          not null, primary key
#  project_id           :integer
#  body                 :text
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  title                :text
#

class Amendment < ActiveRecord::Base
  include PostableByOfficer

  belongs_to :project, touch: true

  private
  def after_post_by_officer(officer)
    project.create_events(:project_amended, project.active_watchers(:vendor), project)
  end

  handle_asynchronously :after_post_by_officer
end
