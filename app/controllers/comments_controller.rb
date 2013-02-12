class CommentsController < ApplicationController
  before_filter :commentable_exists?

  def create
    @comment = @commentable.comments.create(officer_id: current_officer.id, body: params[:body])

    respond_to do |format|
      format.json { render json: @comment, root: false }
    end
  end

  private
  def commentable_exists?
    @commentable = params[:commentable_type].capitalize.constantize.find(params[:commentable_id])
  end
end
