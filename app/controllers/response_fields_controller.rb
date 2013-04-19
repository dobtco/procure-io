class ResponseFieldsController < ApplicationController
  # Load
  before_filter :response_fieldable_exists?
  before_filter :response_field_exists?, only: [:update, :destroy]

  # Authorize
  before_filter { |c| c.authorize! :edit_response_fields, @response_fieldable }

  def create
    @response_field = @response_fieldable.response_fields.create pick(params, *allowed_params)
    render_serialized(@response_field)
  end

  def update
    @response_field.update_attributes pick(params, *allowed_params)
    render_serialized(@response_field)
  end

  def batch
    (params[:response_fields] || []).each do |response_field_params|
      response_field = @response_fieldable.response_fields.find(response_field_params[:id])
      response_field.update_attributes pick(response_field_params, *allowed_params)
    end

    @response_fieldable.update_attributes(form_options: params[:form_options]) if params[:form_options]

    render_serialized(@response_fieldable.response_fields)
  end

  def destroy
    @response_field.destroy
    render json: {}
  end

  private
  def response_fieldable_exists?
    @response_fieldable = if params[:response_fieldable_type] == "GlobalConfig"
      GlobalConfig.instance
    else
      params[:response_fieldable_type].constantize.find(params[:response_fieldable_id])
    end
  end

  def response_field_exists?
    @response_field = @response_fieldable.response_fields.find(params[:id])
  end

  def allowed_params
    [:field_type, :label, :field_options, :sort_order, :key_field, :only_visible_to_admin]
  end
end
