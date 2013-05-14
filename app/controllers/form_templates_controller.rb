class FormTemplatesController < ApplicationController
  # Load
  load_resource only: [:preview, :use, :destroy, :edit]
  before_filter :response_fieldable_exists?, except: [:preview, :index, :destroy, :edit] # also authorizes

  # admin
  def index
    respond_to do |format|
      format.html {}

      format.json do
        search_results = FormTemplate.searcher(params)
        render_serialized search_results[:results], meta: search_results[:meta]
      end
    end
  end

  def edit
  end

  def pick_template
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

  def destroy
    @form_template.destroy
    redirect_to form_templates_path
  end

  private
  def response_fieldable_exists?
    @response_fieldable = find_polymorphic(:response_fieldable)
    authorize! :manage_response_fields, @response_fieldable
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
