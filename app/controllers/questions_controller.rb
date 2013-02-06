class QuestionsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_vendor!

  def create
    question = @project.questions.build(body: params[:body])
    question.vendor_id = current_vendor.id
    question.save
    respond_to do |format|
      format.json { render json: question.to_json }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    # todo can? read project (for when its not yet posted)
  end
end
