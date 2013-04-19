class QuestionsController < ApplicationController
  # Check Enabled
  before_filter { |c| c.check_enabled!('questions') }

  # Load
  load_resource :project
  load_resource :question, through: :project, only: [:update]

  # Authorize
  before_filter :authenticate_vendor!, only: [:create]
  before_filter only: [:index, :update] { |c| c.authorize! :answer_questions, @project }

  def create
    question = @project.questions.create(body: params[:body], vendor_id: current_vendor.id)
    render_serialized(question, VendorQuestionSerializer)
  end

  def index
    current_user.read_notifications(@project, :question_asked)
    @questions = @project.questions.paginate(page: params[:page])
    @questions_json = serialized(@questions, OfficerQuestionSerializer).to_json
  end

  def update
    @question.update_attributes(answer_body: params[:answer_body],
                                officer: !params[:answer_body].blank? ? current_officer : nil)

    render_serialized(@question)
  end
end
