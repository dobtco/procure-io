class ResponseFieldsController < ApplicationController
  before_filter :project_exists?
  before_filter :response_field_exists?, only: :update

  def index
  end

  def create
    @response_field = @project.response_fields.create pick(params, :field_type, :label, :options, :sort_order)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  def update
    @response_field.update_attributes pick(params, :field_type, :label, :options, :sort_order)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :update, @project # only collaborators on this project can view these pages
  end

  def response_field_exists?
    @response_field = @project.response_fields.find(params[:id])
  end
end
