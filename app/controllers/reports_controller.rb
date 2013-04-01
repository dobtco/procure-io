class ReportsController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :project_exists?

  def bids
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end
end
