class ProjectsController < ApplicationController
  before_filter :project_exists?, only: [:show, :edit, :update, :collaborators]
  before_filter :authenticate_officer!, except: [:index, :show]

  def index
    @projects = Project.posted
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
