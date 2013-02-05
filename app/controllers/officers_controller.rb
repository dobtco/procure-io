class OfficersController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!

  def index
    @officers = @project.officers
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :update, @project # only collaborators on this project can view these pages
  end
end
