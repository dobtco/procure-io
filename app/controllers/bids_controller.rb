class BidsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_vendor!, only: [:new]

  def new
    # @todo can? :create @bid
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end
end
