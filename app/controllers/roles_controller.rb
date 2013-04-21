class RolesController < ApplicationController
  before_filter :authorize!
  before_filter :role_exists?, only: [:edit, :update, :destroy]

  def index
    @roles = Role.order("name").paginate(page: params[:page])
  end

  def new
    @role = Role.new
  end

  def create
    logger.info role_params
    Role.create(role_params)
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

  def role_exists?
    @role = Role.find(params[:id])
    return not_found unless (can? :manage, @role)
  end

  def authorize!
    return not_found unless (can? :manage, Role)
  end
end
