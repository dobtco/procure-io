class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!
  before_filter :authorize_officer!

  def index
    current_user.read_notifications(@project, :collaborator_added, :you_were_added)
    @collaborators = @project.collaborators
  end

  def create
    emails = create_collaborator_params[:email].split(',').map{ |e| e.strip }

    emails.each do |email|
      officer = Officer.joins(:user).where(users: { email: email }).first
      officer = Officer.invite!(email, @project, create_collaborator_params[:role_id]) if !officer

      officer.collaborators.where(project_id: @project.id).first_or_create(added_by_officer_id: current_officer.id) if officer.valid?
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

  def create_collaborator_params
    filtered_params = pick(params, :email, :role_id)

    if filtered_params[:role_id]
      role = Role.find(filtered_params[:role_id])
      filtered_params.delete(:role_id) unless role.assignable_by_officer?(current_officer)
    end

    filtered_params
  end
end
