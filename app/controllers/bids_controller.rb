class BidsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_vendor!, only: [:new, :create]

  def new
    # @todo can? :create @bid
    @bid = current_vendor.bids.where(project_id: @project.id).first || @project.bids.build
  end

  def create
    # handle creation and submission?
    @bid = current_vendor.bids.where(project_id: @project.id).first || current_vendor.bids.build(project_id: @project.id)

    params[:response_fields].each do |key, val|
      bid_response = @bid.bid_responses.where(response_field_id: key).first_or_create
      bid_response.update_attributes(value: val)
    end

    @bid.submit unless params[:draft_only] == 'true'

    @bid.save

    redirect_to new_project_bid_path
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end
end
