class ProjectRevisionsController < ApplicationController
  # Load
  load_resource :project
  load_resource :project_revision, through: :project

  # Authorize
  before_filter { |c| c.authorize! :update, @project }

  def show
  end

  def restore
    @project.current_user = current_user
    @project.update_attributes(body: @project_revision.body)
    redirect_to edit_project_path(@project)
  end
end
