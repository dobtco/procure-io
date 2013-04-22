class CollaboratorsController < ApplicationController
  # Load
  load_resource :project
  load_resource :collaborator, through: :project, only: [:destroy, :owner]

  # Authorize
  before_filter except: [:index, :owner] { |c| c.authorize! :add_and_remove_collaborators, @project }

  def index
    current_user.read_notifications(@project, :collaborator_added, :you_were_added, :bulk_collaborators_added)
    @collaborators = @project.collaborators
  end

  def create
    emails = create_collaborator_params[:email].split(',').map{ |e| e.strip }
    added_in_bulk = emails.count > 1
    users = []

    emails.each do |email|
      officer = Officer.joins(:user).where(users: { email: email }).first ||
                Officer.invite!(email, @project, create_collaborator_params[:role_id])

      if officer.valid?
        officer.collaborators
               .where(project_id: @project.id)
               .first_or_create(added_by_officer_id: current_officer.id, added_in_bulk: true)

        users << officer.user
      end
    end

    Collaborator.delay.send_added_in_bulk_events!(users, @project, current_user.id) if added_in_bulk

    @collaborators = @project.collaborators
  end

  def destroy
    authorize! :destroy, @collaborator
    @collaborator.destroy
    render json: {}
  end

  def owner
    authorize! :assign_owner, @project

    if @collaborator.owner # remove ownership
      if @project.owners.count > 1
        @collaborator.update_attributes(owner: false)
      else
        flash[:error] = t('flashes.cant_remove_last_owner')
      end
    else # add ownership
      @collaborator.update_attributes(owner: true)
    end

    redirect_to :back
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
