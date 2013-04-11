class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!
  before_filter :authorize_officer!

  def index
    current_officer.read_notifications(@project, :collaborator_added, :you_were_added)
    @collaborators = @project.collaborators
  end

  def create
    emails = params[:collaborator][:officer][:email].split(',').map{ |e| e.strip }

    emails.each do |email|
      officer = Officer.where(email: email).first || Officer.invite!(email: email)
      officer.collaborators.where(project_id: @project.id).first_or_create(added_by_officer_id: current_officer.id)
    end

    @collaborators = @project.collaborators

    respond_to do |format|
      format.js
    end
  end

  def destroy
    authorize! :destroy, @project # only the owner of the project can remove collaborators
    @project.collaborators.find(params[:id]).destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end

  def authorize_officer!
    authorize! :admin, @project
  end
end
