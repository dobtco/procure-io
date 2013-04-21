class CommentsController < ApplicationController
  # Check Enabled
  before_filter { |c| c.check_enabled!('comments') }

  # Load
  before_filter :commentable_exists?
  load_resource :comment, through: :commentable, only: :destroy

  # Authorize
  before_filter only: [:index, :create] { |c| c.authorize! :"read_and_write_#{@commentable.class.name.downcase}_comments", @commentable }

  def index
    @comments = @commentable.comments
    render_serialized(@comments)
  end

  def create
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
    @commentable = find_polymorphic(:commentable)
    not_found if !@commentable
  end
end
