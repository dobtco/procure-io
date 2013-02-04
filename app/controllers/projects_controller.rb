class ProjectsController < ApplicationController
  before_filter :project_exists?, except: :index

  def index
    @projects = Project.all
  end

  def show
    if can? :update, @project
      render "projects/show"
    else
      render "projects/show_public"
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:id])
  end
end
