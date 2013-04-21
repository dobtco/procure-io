class RolesController < ApplicationController
  # Load
  load_resource :role

  # Authorize
  before_filter :is_admin_or_god

  def index
    @roles = Role.order("name").paginate(page: params[:page])
  end

  def new
  end

  def create
    @role.update_attributes(role_params)
    redirect_to roles_path
  end

  def edit
  end

  def update
    @role.update_attributes(role_params)
    redirect_to roles_path
  end

  def destroy
    @role.destroy unless @role.undeletable?
    redirect_to roles_path
  end

  private
  def role_params
    params.require(:role).permit(:name, permissions: Role.all_permissions_flat)
  end
end
