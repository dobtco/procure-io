class ProjectRevisionsController < ApplicationController
  before_filter :project_exists?
  before_filter :project_revision_exists?
  before_filter :authenticate_officer!
  before_filter :authorize_officer!

  def show
  end

  def restore
    @project.updating_officer_id = current_officer.id
    @project.update_attributes(body: @project_revision.body)
    redirect_to edit_project_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def project_revision_exists?
    @project_revision = @project.project_revisions.find(params[:id])
  end

  def authorize_officer!
    authorize! :collaborate_on, @project
  end
end
