class VendorBidsController < ApplicationController
  include SaveResponsesHelper

  # Load
  load_resource :vendor
  before_filter :load_bid, only: [:show, :edit, :update]
  before_filter :load_project, only: [:create]

  def index
    search_results = Bid.searcher(params, starting_query: @vendor.bids.join_project, vendor_searching: true)

    respond_to do |format|
      format.html do
        @bootstrap_data = serialized(search_results[:results], VendorBidSerializer, meta: search_results[:meta])
      end

      format.json do
        render_serialized search_results[:results], VendorBidSerializer, meta: search_results[:meta]
      end
    end
  end

  def create
    @bid = @vendor.bids.where(project_id: @project.id).create
    redirect_to vendor_bid_path(@vendor, @bid)
  end

  def show
    @bid.submitted ? show_submitted : write
  end

  def show_submitted
    current_user.read_notifications(@bid)

    params[:action] = 'show_submitted'
    render "show_submitted"
  end

  def write
    params[:action] = 'write'
    render "write"
  end

  def update
    save_responses(@bid, @bid.project.response_fields)

    if params[:draft_only] != 'true' && @bid.responsable_valid?
      @bid.submit!
      flash[:success] = @bid.project.form_confirmation_message
    end

    redirect_to vendor_bid_path(@vendor, @bid)
  end

  def edit
    # make sure it's not submitted
  end

  private
  def load_bid
    @bid = @vendor.bids.find(params[:id])
  end

  def load_project
    @project = Project.find(params[:project_id])
  end
end