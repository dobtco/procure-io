class RolesController < ApplicationController
  before_filter :authorize!
  before_filter :build_permission_level_options, only: [:new, :edit]
  before_filter :role_exists?, only: [:edit, :update, :destroy]

  def index
    @roles = Role.order("name").paginate(page: params[:page])
  end

  def new
    @role = Role.new
  end

  def create
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
    filtered_params = params.require(:role).permit(:name, :permission_level)

    if current_officer.permission_level != :god
      filtered_params.delete(:permission_level) if filtered_params[:permission_level] == Role.permission_levels[:god]
    end

    filtered_params
  end

  def role_exists?
    @role = Role.find(params[:id])
    return not_found unless (can? :manage, @role)
  end

  def authorize!
    return not_found unless (can? :manage, Role)
  end

  def build_permission_level_options
    @permission_level_options = current_officer.permission_level == :god ? Role.permission_levels : Role.permission_levels.except(:god)
  end
end
