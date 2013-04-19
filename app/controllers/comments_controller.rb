class CommentsController < ApplicationController
  # Check Enabled
  before_filter { |c| c.check_enabled!('comments') }

  # Load
  before_filter :commentable_exists?
  load_resource :comment, through: :commentable, only: :destroy

  def index
    authorize! :read_comments_about, @commentable
    @comments = @commentable.comments
    render_serialized(@comments)
  end

  def create
    authorize! :comment_on, @commentable
    @comment = @commentable.comments.create(officer_id: current_officer.id, body: params[:body])
    render_serialized(@comment)
  end

  def destroy
    authorize! :destroy, @comment
    @comment.destroy
    render json: {}
  end

  private
  def commentable_exists?
    @commentable = params[:commentable_type].constantize.find(params[:commentable_id])
  end
end
