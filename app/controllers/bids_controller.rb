class BidsController < ApplicationController
  before_filter :project_exists?
  before_filter :bid_exists?, only: [:show]
  before_filter :authenticate_vendor!, only: [:new, :create]
  before_filter :authenticate_officer!, only: [:index]
  before_filter :vendor_has_not_yet_submitted_bid, only: [:new, :create]

  def index
    authorize! :update, @project
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

  def show
    if current_vendor && @bid.vendor = current_vendor
      render "bids/show_vendor"
    elsif current_officer && (can? :update, @project)
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
