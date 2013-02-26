class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!

  def index
    @collaborators_json = ActiveModel::ArraySerializer.new(@project.collaborators).to_json
  end

  def create
    @officer = Officer.where(email: params[:officer][:email]).first || Officer.invite!(email: params[:officer][:email])

    if @officer.projects.where(id: @project.id).first
      respond_to do |format|
        format.json { render json: {error: "Already a collaborator."}, status: 422 }
      end
    else
      @collaborator = @officer.collaborators.create(project_id: @project.id)
      respond_to do |format|
        format.json { render json: @collaborator, root: false }
      end
    end
  end

  def destroy
    authorize! :destroy, @project # only the owner of the project can remove collaborators
    @project.collaborators.find(params[:id]).destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :update, @project # only collaborators on this project can view these pages
  end
end
