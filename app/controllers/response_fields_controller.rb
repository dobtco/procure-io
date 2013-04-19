class ResponseFieldsController < ApplicationController
  # Load
  before_filter :response_fieldable_exists?
  before_filter :response_field_exists?, only: [:update, :destroy, :delete_response]
  before_filter :authenticate_vendor!, only: [:delete_response]
  before_filter :users_response_exists?, only: [:delete_response]

  # Authorize
  before_filter except: [:delete_response] { |c| c.authorize! :edit_response_fields, @response_fieldable }

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

  def delete_response
    authorize! :delete, @response
    @response.destroy
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

  def users_response_exists?
    debugger
    @response = @response_field.responses.joins(:user)
                                         .where(users: {id: current_user.id})
                                         .first
  end

  def allowed_params
    [:field_type, :label, :field_options, :sort_order, :key_field, :only_visible_to_admin]
  end
end
