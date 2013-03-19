class FormTemplatesController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @form_template = FormTemplate.create(name: params[:name],
                                         response_fields: @project.response_fields,
                                         form_description: @project.form_description,
                                         form_confirmation_message: @project.form_confirmation_message)

    respond_to do |format|
      format.json { render json: @form_template }
    end
  end
end
