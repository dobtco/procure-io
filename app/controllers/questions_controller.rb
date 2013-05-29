class QuestionsController < ApplicationController
  # Load
  load_resource :project
  load_resource :question, through: :project

  # Authorize
  before_filter only: [:create] { |c| c.authorize! :ask_question, @project}
  before_filter only: [:index, :update] { |c| c.authorize! :respond_to_questions, @project }

  def create
    @question.update_attributes(body: params[:question][:body], asker: current_user)
  end

  def index
    current_user.read_notifications(@project, :question_asked)
    @questions = @project.questions.paginate(page: params[:page])
    @questions_json = serialized(@questions, include_asker: true).to_json
  end

  def update
    @question.update_attributes(answer_body: params[:answer_body],
                                answerer: params[:answer_body].blank? ? nil : current_user)

    render_serialized(@question)
  end
end
