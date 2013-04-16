class CommentsController < ApplicationController
  before_filter :commentable_exists?, only: [:index, :create]
  before_filter :comment_exists?, only: :destroy
  before_filter :comment_is_mine?, only: :destroy
  before_filter { |c| c.check_enabled!('comments') }

  def index
    @comments = @commentable.comments

    respond_to do |format|
      format.json { render json: @comments, root: false }
    end
  end

  def create
    @comment = @commentable.comments.create(officer_id: current_officer.id, body: params[:body])

    respond_to do |format|
      format.json { render json: @comment, root: false }
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def commentable_exists?
    @commentable = params[:commentable_type].capitalize.constantize.find(params[:commentable_id])
    authorize!(:comment_on, @commentable) if @commentable.class.name == "Project"
  end

  def comment_exists?
    @comment = Comment.find(params[:id])
  end

  def comment_is_mine?
    (current_officer && @comment.officer == current_officer) || (current_vendor && @comment.vendor == current_vendor) || not_found
  end
end
