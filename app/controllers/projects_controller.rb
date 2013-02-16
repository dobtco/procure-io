class ProjectsController < ApplicationController
  before_filter :project_exists?, only: [:show, :edit, :update, :collaborators]
  before_filter :authenticate_officer!, except: [:index, :show]

  def index
    @projects = Project.includes(:tags).posted

    # @todo solr or someshit
    if params[:q]
      @projects = @projects.where("body LIKE ? OR title LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    if params[:category] && !params[:category].blank?
      @projects = @projects.where("tags.name = ?", params[:category])
    end

    # @todo categories

    pagination_info = {
      total: @projects.count,
      per_page: !params[:per_page].blank? ? params[:per_page].to_i : 10,
      page: !params[:page].blank? ? params[:page].to_i : 1
    }

    pagination_info[:last_page] = [(pagination_info[:total].to_f / pagination_info[:per_page]).ceil, 1].max

    if pagination_info[:last_page] < pagination_info[:page]
      pagination_info[:page] = pagination_info[:last_page]
    end

    @projects = @projects.limit(pagination_info[:per_page]).offset((pagination_info[:page] - 1)*pagination_info[:per_page])


    respond_to do |format|
      format.html
      format.json { render json: @projects, meta: pagination_info }
    end
  end

  def mine
    @projects = current_officer.projects
  end

  def show
    @questions_json = ActiveModel::ArraySerializer.new(@project.questions.all, each_serializer: VendorQuestionSerializer).to_json
  end

  def new
    @project = current_officer.projects.build
  end

  def create
    @project = current_officer.projects.create(params[:project])
    @project.collaborators.where(officer_id: current_officer.id).first.update_attributes owner: true
    redirect_to edit_project_path(@project)
  end

  def edit
    authorize! :update, @project
  end

  def update
    authorize! :update, @project
    @project.update_attributes reject(params[:project], :tags)

    @project.tags = []
    params[:project][:tags].split(",").each do |name|
      @tag = Tag.where("lower(name) = ?", name.strip.downcase).first || Tag.create(name: name.strip)
      @project.tags << @tag
    end

    redirect_to edit_project_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:id])
  end
end
