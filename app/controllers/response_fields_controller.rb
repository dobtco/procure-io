class ResponseFieldsController < ApplicationController
  before_filter :project_exists?
  before_filter :response_field_exists?, only: [:update, :destroy]

  def index
  end

  def create
    @response_field = @project.response_fields.create pick(params, *allowed_params)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  def update
    @response_field.update_attributes pick(params, *allowed_params)
    respond_to do |format|
      format.json { render json: @response_field }
    end
  end

  def batch
    if params[:response_fields]
      params[:response_fields].each do |response_field_params|
        response_field = @project.response_fields.find(response_field_params[:id])
        response_field.update_attributes pick(response_field_params, *allowed_params)
      end
    end

    @project.update_attributes pick(params[:project], :form_description, :form_confirmation_message)

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

  def use_template
    @form_templates = FormTemplate.paginate(page: params[:page])
    @template = FormTemplate.find(params[:template_id]) if params[:template_id]
  end

  def post_use_template
    @project.response_fields.destroy_all
    @template = FormTemplate.find(params[:template_id])

    @project.form_description = @template.form_description if @template.form_description
    @project.form_confirmation_message = @template.form_confirmation_message if @template.form_confirmation_message
    @project.save

    @template.response_fields.each do |response_field|
      @project.response_fields << ResponseField.new(response_field)
    end

    redirect_to project_response_fields_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project # only collaborators on this project can view these pages
  end

  def response_field_exists?
    @response_field = @project.response_fields.find(params[:id])
  end

  def allowed_params
    [:field_type, :label, :field_options, :sort_order, :key_field]
  end
end
