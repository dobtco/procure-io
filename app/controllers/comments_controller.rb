class CommentsController < ApplicationController
  # Load
  before_filter :commentable_exists?
  load_resource :comment, through: :commentable, only: :destroy

  # Authorize
  before_filter :authorize_commentable, only: [:index, :create]

  def index
    @comments = @commentable.comments
    render_serialized(@comments)
  end

  def create
    @comment = @commentable.comments.create(user: current_user, body: params[:body])
    render_serialized(@comment)
  end

  def destroy
    authorize! :destroy, @comment
    @comment.destroy
    render json: {}
  end

  private
  def commentable_exists?
    @commentable = find_polymorphic(:commentable)
    not_found if !@commentable
  end

  def authorize_commentable
    case @commentable.class.name
    when "Project"
      authorize! :comment_on, @commentable
    when "Bid"
      authorize! :comment_on, @commentable.project
    end
  end
end
