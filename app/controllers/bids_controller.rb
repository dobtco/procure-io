class BidsController < ApplicationController
  include SaveResponsesHelper

  # Check Enabled
  before_filter only: [:index, :show, :batch, :reviews, :read_notifications, :emails] { |c| c.check_enabled!('bid_review') }
  before_filter only: [:new, :create, :mine] { |c| c.check_enabled!('bid_submission') }

  # Load
  load_resource :project, except: [:mine]
  load_resource :bid, through: :project, except: [:new, :create, :mine]

  # Authorize
  before_filter only: [:index, :update, :batch, :emails, :destroy] { |c| c.authorize! :collaborate_on, @project }
  before_filter only: [:new, :create] { |c| c.authorize! :bid_on, @project }
  before_filter only: [:edit, :post_edit] { |c| c.authorize! :edit, @bid }
  before_filter :authenticate_vendor!, only: [:mine]

  def index
    respond_to do |format|
      format.html do
        current_user.read_notifications(@project, :you_were_added) if current_user
      end

      format.json do
        search_results = Bid.searcher(params,
                                      starting_query: @project.bids
                                                        .includes(:labels, :responses, vendor: [:user, :vendor_profile])
                                                        .joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id")
                                                        .join_my_watches(current_user.id)
                                                        .join_my_bid_review(current_officer.id)
                                                        .submitted,
                                      simpler_query: @project.bids.submitted,
                                      project: @project)

        render_serialized search_results[:results], BidWithReviewSerializer, meta: search_results[:meta]
      end
    end
  end

  def mine
    @bids = current_vendor.bids.includes(:project).order('submitted_at DESC').paginate(page: params[:page])
  end

  def edit
  end

  def post_edit
    save_responses(@bid, @project.response_fields)
    @bid.save
    redirect_to project_bid_path(@project, @bid)
  end

  def new
    @bid = current_vendor.bids.where(project_id: @project.id).first || @project.bids.build
  end

  def create
    @bid = current_vendor.bids.where(project_id: @project.id).first_or_create

    save_responses(@bid, @project.response_fields)

    if params[:draft_only] != 'true' && @bid.responsable_valid?
      @bid.submit
      @bid.save
      flash[:success] = @project.form_confirmation_message
      redirect_to project_bid_path(@project, @bid)
    else
      redirect_to new_project_bid_path
    end
  end

  def update
    if can? :review_bids, @project
      review = @bid.bid_review_for_officer(current_officer)
      review.update_attributes(my_bid_review_params)
    end

    if can? :award_and_dismiss_bids, @project
      if @bid.dismissed? && params[:dismissed_at] == false
        @bid.undismiss_by_officer!(current_officer)
      elsif !@bid.dismissed? && params[:dismissed_at] == true
        @bid.unaward_by_officer(current_officer)
        @bid.dismiss_by_officer!(current_officer, pick(params, :dismissal_message, :show_dismissal_message_to_vendor))
      end

      if @bid.awarded? && params[:awarded_at] == false
        @bid.unaward_by_officer!(current_officer)
      elsif !@bid.awarded? && params[:awarded_at] == true
        @bid.undismiss_by_officer(current_officer)
        @bid.award_by_officer!(current_officer)
      end
    end

    if current_user.watches?(@bid) && !params[:watching]
      current_user.unwatch!(@bid)
    elsif !current_user.watches?(@bid) && params[:watching]
      current_user.watch!(@bid)
    end

    if (can? :label_bids, @project) && params.has_key?(:labels)
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

    case params[:bid_action]
    when "dismiss"
      @bids.each do |bid|
        next if !(can? :award_and_dismiss_bids, @project)
        if bid.dismissed?
          bid.undismiss_by_officer!(current_officer)
        else
          bid.dismiss_by_officer!(current_officer, pick(params[:options], :dismissal_message, :show_dismissal_message_to_vendor))
        end
      end
    when "award"
      @bids.each do |bid|
        next if !(can? :award_and_dismiss_bids, @project)
        if bid.awarded?
          bid.unaward_by_officer!(current_officer)
        else
          bid.award_by_officer!(current_officer)
        end
      end
    when "label"
      @label = @project.labels.find(params[:options][:label_id])

      @bids.each do |bid|
        next if !(can? :label_bids, @project)
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
    authenticate_user!
    current_user.read_notifications(@bid)
    current_vendor ? show_vendor : show_officer
  end

  def show_vendor
    authorize! :read, @bid
    render "bids/show_vendor"
  end

  def show_officer
    authorize! :read, @bid

    if !(review = @bid.bid_review_for_officer(current_officer)).read
      review.update_attributes read: true
    end

    @bid_json = serialized(@bid.reload, BidWithReviewSerializer).to_json
    @comments_json = serialized(@bid.comments).to_json

    if @project.review_mode == Project.review_modes[:stars]
      reviews = @bid.bid_reviews.where(starred: true)
    else # one_through_five
      reviews = @bid.bid_reviews.where("rating IS NOT NULL")
    end


    @reviews_json = serialized(reviews, include_officer: true).to_json
    render "bids/show_officer"
  end

  def reviews
    authorize! :see_all_bid_reviews, @project

    if @project.review_mode == Project.review_modes[:stars]
      reviews = @bid.bid_reviews.where(starred: true)
    else # one_through_five
      reviews = @bid.bid_reviews.where("rating IS NOT NULL")
    end

    render_serialized(reviews, include_officer: true)
  end

  def emails
    search_results = Bid.searcher(params, starting_query: @project.bids.joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id").submitted,
                         project: @project,
                         chainable: true)
                        .reorder("bids.id DESC")
                        .joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id")
                        .joins("LEFT JOIN users ON vendors.id = users.owner_id AND users.owner_type = 'Vendor'")
                        .pluck("users.email")

    render json: search_results.to_json
  end

  def destroy
    authorize! :destroy, @bid
    @bid.destroy
    flash[:success] = I18n.t('flashes.bid_was_destroyed')
    redirect_to project_bids_path(@project)
  end

  private
  def my_bid_review_params
    pick(params, :starred, :read, :rating)
  end
end
