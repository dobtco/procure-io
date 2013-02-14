class ResponseFieldsController < ApplicationController
  before_filter :project_exists?
  before_filter :response_field_exists?, only: [:update, :destroy]

  def index
    logger.info @project.response_fields.inspect
  end

  def create
    @response_field = @project.response_fields.create pick(params, :field_type, :label, :field_options, :sort_order, :key_field)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  def update
    @response_field.update_attributes pick(params, :field_type, :label, :field_options, :sort_order, :key_field)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  def batch
    params[:response_fields].each do |response_field_params|
      response_field = @project.response_fields.find(response_field_params[:id])
      response_field.update_attributes pick(response_field_params, :field_type, :label, :field_options, :sort_order, :key_field)
    end

    respond_to do |format|
      format.json { render json: @project.response_fields }
    end
  end

  def destroy
    @response_field.destroy
    respond_to do |format|
      format.json { render json: {} }
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
