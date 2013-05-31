class ProjectAttachmentsController < ApplicationController
  # Load
  load_resource :project
  load_resource :project_attachment, through: :project

  before_filter { |c| c.authorize! :update, @project }

  def destroy
    @project_attachment.destroy
    render_json_success
  end
end
