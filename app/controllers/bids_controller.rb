class BidsController < ApplicationController
  before_filter :project_exists?
  before_filter :bid_exists?, only: [:show, :update, :reviews]
  before_filter :authenticate_and_authorize_vendor!, only: [:new, :create]
  before_filter :authenticate_and_authorize_officer!, only: [:index, :reviews]

  def index
    respond_to do |format|
      format.html {}

      format.json do
        @bids = @project.submitted_bids.includes(:labels)
                                       .includes(:bid_responses)
                                       .includes(:vendor)
                                       .includes(:project)
                                       .includes(:my_bid_review)
                                       .joins("LEFT JOIN bid_reviews as my_bid_review ON my_bid_review.bid_id = bids.id")
                                       .where("my_bid_review.officer_id = ? OR my_bid_review.officer_id IS NULL", current_officer.id)

        if params[:f2] == "dismissed"
          @bids = @bids.where("dismissed_at IS NOT NULL AND awarded_at IS NULL")
        elsif params[:f2] == "awarded"
          @bids = @bids.where("dismissed_at IS NULL AND awarded_at IS NOT NULL")
        else
          @bids = @bids.where("dismissed_at IS NULL AND awarded_at IS NULL")
        end

        if params[:f1] == "starred"
          @bids = @bids.where("total_stars > 0")
        end

        if params[:sort].to_i > 0
          @bids = @bids.joins("LEFT JOIN bid_responses ON bid_responses.bid_id = bids.id")
                       .where("bid_responses.response_field_id = ?", params[:sort])
                       .order("bid_responses.value #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
        elsif params[:sort] == "stars"
          @bids = @bids.order("total_stars #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
        elsif params[:sort] == "createdAt" || !params[:sort]
          @bids = @bids.order("bids.created_at #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
        end

        if params[:label] && !params[:label].blank?
          @bids = @bids.joins("LEFT JOIN bids_labels ON bids.id = bids_labels.bid_id LEFT JOIN labels ON labels.id = bids_labels.label_id")
                       .where("labels.name = ?", params[:label])
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

        render json: @bids, each_serializer: BidWithReviewSerializer, scope: current_officer, meta: pagination_info
      end
    end
  end

  def new
    @bid = current_vendor.bids.where(project_id: @project.id).first || @project.bids.build
  end

  def create
    @bid = current_vendor.bids.where(project_id: @project.id).first_or_create

    bid_errors = []

    @project.response_fields.each do |response_field|
      bid_response = @bid.bid_responses.where(response_field_id: response_field.id).first_or_create

      case response_field.field_type
      when "text", "paragraph", "dropdown", "radio"
        bid_response.update_attributes(value: params[:response_fields][response_field.id.to_s])
      when "checkboxes"
        values = {}

        response_field.field_options["options"].each_with_index do |option, index|
          label = response_field.field_options["options"][index]["label"]
          values[option["label"]] = params[:response_fields][response_field.id.to_s] ? "true" : "false"
        end

        bid_response.update_attributes(value: values.to_yaml)
      end
    end

    @bid.save

    if params[:draft_only] != 'true' && @bid.valid_bid?
      @bid.submit
      @bid.save
      return redirect_to project_bid_path(@project, @bid)
    end

    redirect_to new_project_bid_path
  end

  def update
    if current_vendor && @bid.vendor == current_vendor
      # vendor is updating bid?
    elsif current_officer && (can? :collaborate_on, @project)
      # officer is reviewing bid
      review = @bid.bid_review_for_officer(current_officer)
      review.assign_attributes my_bid_review_params
      review.save

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

      @bid.labels = []

      (params[:labels] || []).each do |label|
        if label["id"]
          @bid.labels << @project.labels.find(label["id"])
        else
          @bid.labels << @project.labels.where(name: label["name"]).first
        end
      end

      @bid.reload # get updated total_stars

      respond_to do |format|
        format.json { render json: @bid, serializer: BidWithReviewSerializer, root: false }
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
        if bid.dismissed?
          bid.undismiss_by_officer!(current_officer)
        else
          bid.dismiss_by_officer!(current_officer)
        end
      end
    when "award"
      @bids.each do |bid|
        if bid.awarded?
          bid.unaward_by_officer!(current_officer)
        else
          bid.award_by_officer!(current_officer)
        end
      end
    when "label"
      @label = @project.labels.where(name: params[:options][:label_name]).first

      @bids.each do |bid|
        if bid.labels.where(name: params[:options][:label_name]).first
          bid.labels.destroy(@label)
        else
          bid.labels << @label
        end
      end
    end

    render json: {}
  end

  def show
    if current_vendor && @bid.vendor == current_vendor
      render "bids/show_vendor"
    elsif current_officer && (can? :collaborate_on, @project)
      return not_found if !@bid.submitted_at

      current_officer.read_notifications(@bid, "BidComment")

      if !(review = @bid.bid_review_for_officer(current_officer)).read
        review.update_attributes read: true
      end

      @bid_json = BidWithReviewSerializer.new(@bid, scope: current_officer, root: false).to_json
      @comments_json = ActiveModel::ArraySerializer.new(@bid.comments, each_serializer: CommentSerializer, root: false).to_json
      render "bids/show_officer"
    else
      redirect_to project_path(@project)
    end
  end

  def reviews
    @reviews = @bid.bid_reviews.where(starred: true)

    respond_to do |format|
      format.json { render json: @reviews }
    end
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
    params.require(:my_bid_review).permit(:starred, :read)
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
