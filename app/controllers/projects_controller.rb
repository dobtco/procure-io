class ProjectsController < ApplicationController
  before_filter :project_exists?, only: [:show, :edit, :update]
  # before filter project is mine
  before_filter :authenticate_officer!, except: [:index, :show]

  def index
    @projects = Project.posted
  end

  def mine
    @projects = current_officer.projects
  end

  def show
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
  end

  def update
    @project.update_attributes params[:project]
    redirect_to edit_project_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:id])
  end
end
