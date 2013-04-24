class FormTemplatesController < ApplicationController
  # Load
  before_filter :response_fieldable_exists?

  # Authorize
  before_filter { |c| c.authorize! :manage_response_fields, @response_fieldable }

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

  private
  def response_fieldable_exists?
    @response_fieldable = find_polymorphic(:response_fieldable)
    not_found unless @response_fieldable
  end

  def form_template_params
    params.require(:form_template).permit(:name)
  end
end
