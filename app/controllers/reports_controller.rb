class ReportsController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :project_exists?

  def bids_over_time
    dates = @project.posted_at.to_date..Time.now.to_date
    bids = @project.bids.submitted
    @data = []

    dates.each do |d|
      @data.push({
        x: d.strftime("%s").to_i,
        y: bids.select { |b| b.submitted_at.to_date == d }.length
      })
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end
end
