class BidsController < ApplicationController
  before_filter :project_exists?
  before_filter :bid_exists?, only: [:show, :update]
  before_filter :authenticate_vendor!, only: [:new, :create]
  before_filter :authenticate_officer!, only: [:index]
  before_filter :vendor_has_not_yet_submitted_bid, only: [:new, :create]

  # @todo too many queries, this is slow
  def index
    authorize! :update, @project

    @bids = @project.bids

    if params[:f2] == "dismissed"
      @bids = @bids.where("dismissed_at IS NOT NULL")
    else
      @bids = @bids.where("dismissed_at IS NULL")
    end

    if params[:f1] == "starred"
      @bids = @bids.where("total_stars > 0")
    end

    pagination_info = {
      total: @bids.count,
      per_page: !params[:per_page].blank? ? params[:per_page].to_i : 10,
      page: !params[:page].blank? ? params[:page].to_i : 1
    }

    pagination_info[:last_page] = [(pagination_info[:total].to_f / pagination_info[:per_page]).ceil, 1].max

    if pagination_info[:last_page] < pagination_info[:page]
      pagination_info[:page] = pagination_info[:last_page]
    end

    @bids = @bids.limit(pagination_info[:per_page]).offset((pagination_info[:page] - 1)*pagination_info[:per_page])

    respond_to do |format|
      format.html
      format.json { render json: @bids, each_serializer: BidWithReviewSerializer, scope: current_officer,
                           meta: pagination_info }
    end
  end

  def new
    # @todo can? :create @bid
    @bid = current_vendor.bids.where(project_id: @project.id).first || @project.bids.build
  end

  def create
    # handle creation and submission?
    @bid = current_vendor.bids.where(project_id: @project.id).first_or_create

    params[:response_fields].each do |key, val|
      bid_response = @bid.bid_responses.where(response_field_id: key).first_or_create
      bid_response.update_attributes(value: val)
    end

    @bid.submit unless params[:draft_only] == 'true'

    @bid.save

    redirect_to new_project_bid_path
  end

  def update
    if current_vendor && @bid.vendor == current_vendor
      # vendor is updating bid?
    elsif current_officer && (can? :update, @project)
      # officer is reviewing bid
      review = @bid.bid_review_for_officer(current_officer)
      review.assign_attributes pick(params[:my_bid_review], :starred, :read)
      review.save

      @bid.reload # get updated total_stars

      respond_to do |format|
        format.json { render json: @bid, serializer: BidWithReviewSerializer }
      end
    else
      render status: 404
    end
  end

  def batch
    # @todo security
    @bids = Bid.find(params[:ids])

    case params[:bid_action]
    when "dismiss"
      @bids.each do |bid|
        if bid.dismissed?
          bid.undismiss!
        else
          bid.dismiss_by_officer!(current_officer)
        end
      end
    end

    render json: {}
  end

  def show
    if current_vendor && @bid.vendor == current_vendor
      render "bids/show_vendor"
    elsif current_officer && (can? :update, @project)
      @bid_json = BidWithReviewSerializer.new(@bid, scope: current_officer, root: false).to_json
      render "bids/show_officer"
    else
      redirect_to project_path(@project)
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def bid_exists?
    @bid = @project.bids.find(params[:id])
  end

  def vendor_has_not_yet_submitted_bid
    if current_vendor.submitted_bid_for_project(@project)
      redirect_to @project
    end
  end
end
