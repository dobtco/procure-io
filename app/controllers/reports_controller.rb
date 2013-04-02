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

  def response_field
    @response_field = @project.response_fields.find(params[:response_field_id])
    @data = []

    max = @response_field.bid_responses.order("sortable_value DESC").first.value.to_f
    interval = max / 5

    ranges = []
    counter = 0
    5.times do |i|
      ranges.push counter..(counter + interval)
      counter = counter + interval
    end

    ranges.each_with_index do |range, i|
      @data.push({
        x: i,
        y: @project.bids.includes(:bid_responses).select { |bid|
          range.cover?(bid.bid_responses.where(response_field_id: @response_field.id).first.value.to_f)
        }.length
      })
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end
end
