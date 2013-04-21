class ProjectRevisionsController < ApplicationController
  # Load
  load_resource :project
  load_resource :project_revision, through: :project

  # Authorize
  before_filter { |c| c.authorize! :edit_project_details, @project }

  def show
  end

  def restore
    @project.updating_officer_id = current_officer.id
    @project.update_attributes(body: @project_revision.body)
    redirect_to edit_project_path(@project)
  end
end
