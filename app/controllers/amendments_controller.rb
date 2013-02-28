class AmendmentsController < ApplicationController
  before_filter :project_exists?
  before_filter :amendment_exists?, only: [:show]
  before_filter :authenticate_and_authorize_officer!, only: [:index]

  def index
  end

  def create
    @amendment = @project.amendments.create
    redirect_to project_amendment_path(@project, @amendment)
  end

  def show
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def amendment_exists?
    @amendment = @project.amendments.find(params[:id])
  end

  def authenticate_and_authorize_officer!
    authenticate_officer!
    authorize! :collaborate_on, @project
  end
end
