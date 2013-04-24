class FormTemplatesController < ApplicationController
  # Load
  load_resource only: [:preview, :use]
  before_filter :response_fieldable_exists?, except: [:preview]

  # Authorize
  before_filter except: [:preview] { |c| c.authorize! :manage_response_fields, @response_fieldable }

  def index
    @form_templates = FormTemplate.paginate(page: params[:page])
  end

  def create
    response_fields = []

    @response_fieldable.response_fields.each do |response_field|
      response_fields.push pick(response_field, :label, :field_type, :field_options, :sort_order, :key_field)
    end

    @form_template = FormTemplate.create(name: form_template_params[:name],
                                         response_fields: response_fields,
                                         form_options: @response_fieldable.form_options)

    render json: @form_template
  end

  def preview
  end

  def use
    @response_fieldable.use_form_template!(@form_template)
    flash[:success] = "Successfully copied form from template."
    redirect_to redirect_path_for(@response_fieldable)
  end

  private
  def response_fieldable_exists?
    @response_fieldable = find_polymorphic(:response_fieldable)
  end

  def form_template_params
    params.require(:form_template).permit(:name)
  end

  def redirect_path_for(response_fieldable)
    case response_fieldable.class.name
    when "Project"
      response_fields_project_path(response_fieldable.id)
    else
      :back
    end
  end
end

# From projects controller:

  # def use_response_field_template
  #   @form_templates = FormTemplate.paginate(page: params[:page])
  #   @template = FormTemplate.find(params[:template_id]) if params[:template_id]
  # end

  # def post_use_response_field_template
  #   @project.response_fields.destroy_all
  #   @template = FormTemplate.find(params[:template_id])

  #   @project.form_options = @template.form_options
  #   @project.save

  #   @template.response_fields.each do |response_field|
  #     @project.response_fields << ResponseField.new(response_field)
  #   end

  #   redirect_to project_response_fields_path(@project)
  # end

