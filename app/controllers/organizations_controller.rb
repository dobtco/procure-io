class OrganizationsController < ApplicationController
  # Load
  load_resource

  # Authorize
  before_filter :authorize, except: [:show]
  before_filter only: [:admin] { |c| c.authorize! :collaborate_on, @organization }
  before_filter only: [:edit, :update, :members, :destroy] { |c| c.authorize! :admin, @organization }

  def admin
    current_user.read_notifications(@organization)
    redirect_to organization_projects_path(@organization)
  end

  def show
    @projects = @organization.projects.posted.limit(5)
  end

  def edit
    current_user.read_notifications(@organization)
  end

  def update
    if @organization.update_attributes(organization_params)
      flash[:success] = "Successfully updated organization info."
      redirect_to edit_organization_path(@organization)
    else
      render :edit
    end
  end

  def members
    search_results = User.searcher(params, starting_query: @organization.users)

    respond_to do |format|
      format.html do
        @bootstrap_data = serialized search_results[:results], meta: search_results[:meta]
      end

      format.json do
        render_serialized search_results[:results], meta: search_results[:meta]
      end
    end
  end

  def destroy
    @organization.destroy
    redirect_to root_path
  end

  private
  def organization_params
    params.require(:organization).permit(:name, :email, :username, :logo, :remove_logo)
  end
end
