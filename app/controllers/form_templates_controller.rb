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
    flash[:success] = t('flashes.copied_form_template')
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
