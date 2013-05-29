class OrganizationProjectsController < ApplicationController
  load_resource :organization
  before_filter :load_project, only: [:new, :create]

  before_filter only: [:index, :new, :create] { |c| c.authorize! :collaborate_on, @organization }

  def index
    search_results = Project.searcher(params, starting_query: @organization.projects, allow_additional_sort_options: true)

    respond_to do |format|
      format.html do
        @bootstrap_data = serialized(search_results[:results], MyProjectSerializer, meta: search_results[:meta])
      end

      format.json do
        render_serialized search_results[:results], MyProjectSerializer, meta: search_results[:meta]
      end
    end
  end

  def new
  end

  def create
    @project.update_attributes(project_params)
    redirect_to edit_project_path(@project)
  end

  private
  def load_project
    @project = params.has_key?(:id) ? @organization.projects.find(params[:id]) : @organization.projects.build
  end

  def project_params
    params.require(:project).permit(:title)
  end
end
