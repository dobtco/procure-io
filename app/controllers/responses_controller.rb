class ResponsesController < ApplicationController
  before_filter :project_exists?
  before_filter :bid_exists?
  before_filter :authenticate_and_authorize_vendor!
  before_filter :response_exists?

  def destroy
    @response.destroy

    respond_to do |format|
      format.json { render json: {status: "success"} }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def bid_exists?
    @bid = @project.bids.find(params[:bid_id])
  end

  def response_exists?
    @response = @bid.responses.find(params[:id])
  end

  def authenticate_and_authorize_vendor!
    authenticate_vendor!
    authorize! :create, @project.bids.build
  end
end
