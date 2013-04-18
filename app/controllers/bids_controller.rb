class BidsController < ApplicationController
  include SaveResponsesHelper

  before_filter :project_exists?
  before_filter :bid_exists?, only: [:show, :update, :reviews, :destroy, :read_notifications]
  before_filter :authenticate_user!, only: [:read_notifications]
  before_filter :authenticate_and_authorize_vendor!, only: [:new, :create]
  before_filter :authenticate_and_authorize_officer!, only: [:index, :reviews, :destroy, :emails]
  before_filter only: [:index, :show, :batch, :reviews, :read_notifications, :emails] { |c| c.check_enabled!('bid_review') }
  before_filter only: [:new, :create] { |c| c.check_enabled!('bid_submission') }

  def index
    current_user.read_notifications(@project, :you_were_added) if current_user

    respond_to do |format|
      format.html {}

      format.json do
        search_results = Bid.searcher(params,
                                      starting_query: @project.bids.joins("LEFT JOIN vendors ON bids.vendor_id = vendors.id").submitted,
                                      project: @project)

        render_serialized search_results[:results], BidWithReviewSerializer, meta: search_results[:meta]
      end
    end
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
      flash[:success] = @project.form_options["form_confirmation_message"] if @project.form_options["form_confirmation_message"]
      redirect_to project_bid_path(@project, @bid)
    else
      redirect_to new_project_bid_path
    end
  end

  def update
    if current_vendor && @bid.vendor == current_vendor
      # vendor is updating bid?
    elsif current_officer && (can? :collaborate_on, @project)
      # officer is reviewing bid
      review = @bid.bid_review_for_officer(current_officer)
      review.assign_attributes my_bid_review_params
      review.save

      if can? :award_dismiss, @bid
        if @bid.dismissed? && params[:dismissed_at] == false
          @bid.undismiss_by_officer!(current_officer)
        elsif !@bid.dismissed? && params[:dismissed_at] == true
          @bid.unaward_by_officer(current_officer)
          @bid.dismiss_by_officer!(current_officer)
        end

        if @bid.awarded? && params[:awarded_at] == false
          @bid.unaward_by_officer!(current_officer)
        elsif !@bid.awarded? && params[:awarded_at] == true
          @bid.undismiss_by_officer(current_officer)
          @bid.award_by_officer!(current_officer)
        end
      end

      if can? :watch, @bid
        if current_user.watches?("Bid", @bid) && !params[:watching]
          current_user.unwatch!("Bid", @bid)
        elsif !current_user.watches?("Bid", @bid) && params[:watching]
          current_user.watch!("Bid", @bid)
        end
      end

      if can? :label, @bid
        @bid.labels = []

        (params[:labels] || []).each do |label|
          if label["id"]
            @bid.labels << @project.labels.find(label["id"])
          else
            @bid.labels << @project.labels.where(name: label["name"]).first
          end
        end
      end

      @bid.reload # get updated total_stars

      respond_to do |format|
        format.json { render_serialized(@bid, BidWithReviewSerializer) }
      end
    else
      render status: 404
    end
  end

  def batch
    @bids = @project.bids.find(params[:ids])

    case params[:bid_action]
    when "dismiss"
      @bids.each do |bid|
        next if !(can? :award_dismiss, bid)
        if bid.dismissed?
          bid.undismiss_by_officer!(current_officer)
        else
          bid.dismiss_by_officer!(current_officer)
        end
      end
    when "award"
      @bids.each do |bid|
        next if !(can? :award_dismiss, bid)
        if bid.awarded?
          bid.unaward_by_officer!(current_officer)
        else
          bid.award_by_officer!(current_officer)
        end
      end
    when "label"
      @label = @project.labels.where(name: params[:options][:label_name]).first

      @bids.each do |bid|
        next if !(can? :label, bid)
        if bid.labels.where(name: params[:options][:label_name]).first
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

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  def show
    return not_found unless current_user

    current_user.read_notifications(@bid)

    if current_vendor && @bid.vendor == current_vendor
      render "bids/show_vendor"

    elsif current_officer && (can? :collaborate_on, @project)
      return not_found if !@bid.submitted_at

      if !(review = @bid.bid_review_for_officer(current_officer)).read
        review.update_attributes read: true
      end

      @bid_json = serialized(@bid, BidWithReviewSerializer).to_json
      @comments_json = serialized(@bid.comments).to_json
      render "bids/show_officer"
    else
      redirect_to project_path(@project)
    end
  end

  def reviews
    @reviews = @bid.bid_reviews.where(starred: true)

    respond_to do |format|
      format.json { render_serialized(@reviews) }
    end
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
    flash[:success] = "Bid was successfully destroyed."
    redirect_to project_bids_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def bid_exists?
    @bid = @project.bids.find(params[:id])
  end

  def bid_params
  end

  def my_bid_review_params
    params.require(:my_bid_review).permit(:starred, :read, :rating)
  end

  def authenticate_and_authorize_officer!
    authenticate_officer!
    authorize! :collaborate_on, @project
  end

  def authenticate_and_authorize_vendor!
    authenticate_vendor!
    authorize! :create, @project.bids.build
  end
end
