class CollaboratorsController < ApplicationController
  # Load
  load_resource :project
  load_resource :collaborator, through: :project, only: [:destroy]

  # Authorize
  before_filter except: [:index] { |c| c.authorize! :add_and_remove_collaborators, @project }

  def index
    current_user.read_notifications(@project, :collaborator_added, :you_were_added)
    @collaborators = @project.collaborators
  end

  def create
    emails = create_collaborator_params[:email].split(',').map{ |e| e.strip }

    emails.each do |email|
      officer = Officer.joins(:user).where(users: { email: email }).first ||
                Officer.invite!(email, @project, create_collaborator_params[:role_id])

      if officer.valid?
        officer.collaborators.where(project_id: @project.id).first_or_create(added_by_officer_id: current_officer.id)
      end
    end
    @collaborators = @project.collaborators
  end

  def destroy
    authorize! :destroy, @collaborator
    @collaborator.destroy
    render json: {}
  end

  private
  def create_collaborator_params
    filtered_params = pick(params, :email, :role_id)

    if filtered_params[:role_id]
      role = Role.find(filtered_params[:role_id])
      filtered_params.delete(:role_id) unless user_is_admin_or_god? && !role.is_god?
    end

    filtered_params
  end
end
