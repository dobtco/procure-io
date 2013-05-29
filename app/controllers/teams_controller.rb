class TeamsController < ApplicationController
  # Load
  load_resource :organization
  load_resource :team, through: :organization

  # Authorize
  # @screendoor!
  before_filter { |c| c.authorize! :admin, @organization }

  def index
    search_results = Team.searcher(params, starting_query: @organization.teams)

    respond_to do |format|
      format.html do
        @bootstrap_data = serialized search_results[:results], meta: search_results[:meta]
      end

      format.json do
        render_serialized search_results[:results], meta: search_results[:meta]
      end
    end
  end

  def new
  end

  def create
    @team.update_attributes(team_params)
    redirect_to edit_organization_team_path(@organization, @team)
  end

  def edit
  end

  def update
    @team.update_attributes(team_params)
    flash[:success] = "Successfully updated team."
    redirect_to edit_organization_team_path(@organization, @team)
  end

  def destroy
    @team.destroy unless @team.is_owners
    redirect_to organization_teams_path(@organization)
  end

  def members
  end

  def add_member
    @user = User.where(email: params[:email]).first ||
            User.invite!(params[:email], current_user)

    if @user
      @team.organization_team_members.create(user: @user, added_by_user: current_user)
    end
  end

  def remove_member
    @user = User.find(params[:user_id])
    @team.users.delete(@user)
    render_json_success
  end

  private
  def team_params
    filtered_params = params.require(:team).permit(:name, :permission_level)
    filtered_params.delete(:permission_level) if filtered_params[:permission_level] == Team.permission_levels[:owner]
    filtered_params
  end
end
