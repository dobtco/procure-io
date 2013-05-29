class BidsController < ApplicationController
  include SaveResponsesHelper

  # Load
  load_resource :project
  load_resource :bid, through: :project

  # Authorize
  before_filter only: [:index, :update, :batch, :emails] { |c| c.authorize! :collaborate_on, @project }
  before_filter only: [:create] { |c| c.authorize! :read, @project }
  before_filter only: [:edit, :post_edit] { |c| c.authorize! :edit_bids, @project }

  def index
    search_results = Bid.searcher(params,
                                  starting_query: @project.bids
                                                    .includes(:labels, :responses, :vendor)
                                                    .joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id")
                                                    .join_my_watches(current_user.id)
                                                    .join_my_bid_review(current_user.id)
                                                    .submitted,
                                  simpler_query: @project.bids.submitted,
                                  project: @project,
                                  include_meta_info: true)

    respond_to do |format|
      format.html do
        current_user.read_notifications(@project, :added_your_team_to_project) if current_user
        @bootstrap_data = serialized(search_results[:results], BidWithReviewSerializer, meta: search_results[:meta])
      end

      format.json do
        render_serialized search_results[:results], BidWithReviewSerializer, meta: search_results[:meta]
      end
    end
  end

  def edit
  end

  def post_edit
    save_responses(@bid, @project.response_fields)
    @bid.save
    redirect_to project_bid_path(@project, @bid)
  end

  def create
    vendor = Vendor.find(params[:bid][:vendor_id])
    not_found unless (can? :collaborate_on, vendor)
    @bid.update_attributes(vendor: vendor)
    redirect_to vendor_bid_path(vendor, @bid)
  end

  def update
    review = @bid.bid_review_for_user(current_user)
    review.update_attributes(my_bid_review_params)

    # @screendoor don't unaward and dismiss in one fell swoop.
    if can? :dismiss_bids, @project
      if @bid.dismissed? && params[:dismissed_at] == false
        @bid.undismiss!(current_user)
      elsif !@bid.dismissed? && params[:dismissed_at] == true
        @bid.unaward(current_user)
        @bid.dismiss!(current_user, pick(params, :dismissal_message, :show_dismissal_message_to_vendor))
      end
    end

    if can? :award_bids, @project
      if @bid.awarded? && params[:awarded_at] == false
        @bid.unaward!(current_user)
      elsif !@bid.awarded? && params[:awarded_at] == true
        @bid.undismiss(current_user)
        @bid.award!(current_user, pick(params, :award_message))
      end
    end

    if (can? :manage_labels, @project) && params.has_key?(:labels)
      @bid.labels = []

      (params[:labels] || []).each do |label_id|
        @bid.labels << @project.labels.find(label_id)
      end
    end

    @bid.reload # get updated total_stars
    render_serialized(@bid, BidWithReviewSerializer)
  end

  def batch
    @bids = @project.bids.find(params[:ids])

    if params[:bid_action] == "dismiss" && (can? :dismiss_bids, @project)
      @bids.each do |bid|
        if bid.dismissed?
          bid.undismiss!(current_user)
        else
          bid.dismiss!(current_user, pick(params[:options], :dismissal_message, :show_dismissal_message_to_vendor))
        end
      end

    elsif params[:bid_action] == "award" && (can? :award_bids, @project)
      @bids.each do |bid|
        if bid.awarded?
          bid.unaward!(current_user)
        else
          bid.award!(current_user, pick(params[:options], :award_message))
        end
      end

    elsif params[:bid_action] == "label" && (can? :manage_labels, @project)
      @label = @project.labels.find(params[:options][:label_id])
      @bids.each do |bid|
        if bid.labels.where(id: @label.id).first
          bid.labels.destroy(@label)
        else
          bid.labels << @label
        end
      end
    end

    render json: {}
  end

  def read_notifications
    current_user.read_notifications(@bid)
    render json: {}
  end

  def show
    authorize! :read, @bid
    current_user.read_notifications(@bid)

    if !(review = @bid.bid_review_for_user(current_user)).read
      review.update_attributes read: true
    end

    @bid_json = serialized(@bid.reload, BidWithReviewSerializer).to_json
    @comments_json = serialized(@bid.comments).to_json

    if @project.review_mode == Project.review_modes[:stars]
      reviews = @bid.bid_reviews.where(starred: true)
    else # one_through_five
      reviews = @bid.bid_reviews.where("rating IS NOT NULL")
    end

    @reviews_json = serialized(reviews, include_user: true).to_json
  end

  def reviews
    authorize! :see_all_reviews, @project

    if @project.review_mode == Project.review_modes[:stars]
      reviews = @bid.bid_reviews.where(starred: true)
    else # one_through_five
      reviews = @bid.bid_reviews.where("rating IS NOT NULL")
    end

    render_serialized(reviews, include_user: true)
  end

  def emails
    search_results = Bid.searcher(params, starting_query: @project.bids.joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id").submitted,
                         project: @project,
                         chainable: true)
                        .reorder("bids.id DESC")
                        .pluck("vendors.email")

    render json: search_results.to_json
  end

  def destroy
    authorize! :destroy, @bid
    @bid.destroy
    flash[:success] = I18n.t('flashes.bid_was_destroyed')

    if can? :collaborate_on, @project
      redirect_to project_bids_path(@project)
    else
      redirect_to project_path(@project)
    end
  end

  private
  def my_bid_review_params
    pick(params, :starred, :read, :rating)
  end
end
