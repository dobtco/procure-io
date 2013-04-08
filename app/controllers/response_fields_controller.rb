class ResponseFieldsController < ApplicationController
  before_filter :response_fieldable_exists?
  before_filter :response_field_exists?, only: [:update, :destroy]

  def create
    @response_field = @response_fieldable.response_fields.create pick(params, *allowed_params)
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
        response_field = @response_fieldable.response_fields.find(response_field_params[:id])
        response_field.update_attributes pick(response_field_params, *allowed_params)
      end
    end

    # @response_fieldable.update_attributes pick(params[:project], :form_description, :form_confirmation_message)

    respond_to do |format|
      format.json { render json: @response_fieldable.response_fields }
    end
  end

  def destroy
    @response_field.destroy
    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def response_fieldable_exists?
    @response_fieldable = if params[:response_fieldable_type] == "GlobalConfig"
      GlobalConfig.instance
    else
      params[:response_fieldable_type].constantize.find(params[:response_fieldable_id])
    end

    authorize! :edit_response_fields, @response_fieldable # only collaborators on this project can view these pages
  end

  def response_field_exists?
    @response_field = @response_fieldable.response_fields.find(params[:id])
  end

  def allowed_params
    [:field_type, :label, :field_options, :sort_order, :key_field]
  end
end
