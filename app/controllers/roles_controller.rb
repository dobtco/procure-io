class RolesController < ApplicationController
  # Load
  load_resource :role, except: [:create]

  # Authorize
  before_filter :is_admin_or_god

  def index
    @roles = Role.not_god.order("name").paginate(page: params[:page])
  end

  def new
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
    if @role.default
      flash[:error] = I18n.t('flashes.cant_delete_default_role')
    elsif @role.undeletable?
      flash[:error] = I18n.t('flashes.role_undeletable')
    else
      flash[:error] = I18n.t('flashes.users_role_deleted', count: @role.officers.count) if @role.officers.count > 0
      @role.destroy
    end

    redirect_to roles_path
  end

  def set_as_default
    Role.where(default: true).update_all(default: false)
    @role.update_attributes(default: true)
    redirect_to :back
  end

  private
  def role_params
    params.require(:role).permit(:name, permissions: Role.all_permissions_flat)
  end
end
