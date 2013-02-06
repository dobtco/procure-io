# @todo active_model_serializers and grape?

class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!

  def index
    @officers = @project.officers
  end

  def create
    @officer = Officer.where(email: params[:email]).first

    if !@officer
      respond_to do |format|
        format.json { render json: {error: "User not found."}, status: 422 }
        # @todo send user an invite anyway.
      end
    elsif @officer.projects.where(id: @project.id).first
      respond_to do |format|
        format.json { render json: {error: "Already a collaborator."}, status: 422 }
      end
    else
      @project.officers << @officer
      respond_to do |format|
        format.json { render json: @officer }
      end
    end
  end

  def destroy
    authorize! :destroy, @project # only the owner of the project can remove collaborators
    @project.collaborators.where(officer_id: params[:id], owner: false).first.destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  def typeahead
    render json: {}
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :update, @project # only collaborators on this project can view these pages
  end
end
