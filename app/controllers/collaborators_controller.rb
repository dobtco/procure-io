class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!

  def index
    @collaborators = @project.collaborators
  end

  def create
    @officer = Officer.where(email: params[:collaborator][:officer][:email]).first

    if @officer && !@project.officers.where(id: @officer.id).first
      @project.officers << @officer
    end

    redirect_to(:back)
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :update, @project # only collaborators on this project can view these pages
  end
end
