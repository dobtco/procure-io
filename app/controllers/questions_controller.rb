class QuestionsController < ApplicationController
  before_filter :project_exists?
  before_filter :question_exists?, only: [:update]
  before_filter :authenticate_vendor!, only: [:create]
  before_filter :authenticate_officer!, only: [:index, :update]

  def create
    question = @project.questions.build(body: params[:body])
    question.vendor_id = current_vendor.id
    question.save
    respond_to do |format|
      format.json { render json: question, serializer: VendorQuestionSerializer }
    end
  end

  def index
    authorize! :update, @project # only collaborators can answer questions
    @questions = @project.questions.paginate(page: params[:page])
    @questions_json = ActiveModel::ArraySerializer.new(@questions,
                                                       each_serializer: OfficerQuestionSerializer).to_json
  end

  def update
    authorize! :update, @project # only collaborators can answer questions
    @question.assign_attributes(answer_body: params[:answer_body])

    if params[:answer_body]
      @question.officer = current_officer
    else
      @question_officer = nil
    end

    @question.save

    respond_to do |format|
      format.json { render json: @question.to_json }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    # todo can? read project (for when its not yet posted)
  end

  def question_exists?
    @question = @project.questions.find(params[:id])
    # todo can? read project (for when its not yet posted)
  end
end
