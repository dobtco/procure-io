class ReportsController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :project_exists?

  def bids_over_time
    dates = @project.posted_at.to_date..([Time.now, @project.bids_due_at].min).to_date
    bids = @project.bids.submitted
    @data = [['Date', '# of bids']]

    dates.each do |d|
      @data.push [ d.to_time.to_formatted_s(:readable_dateonly), bids.select { |b| b.submitted_at.to_date == d }.length ]
    end
  end

  def impressions
    first_impression = @project.impressions.order("created_at").first
    last_impression = @project.impressions.order("created_at").last

    if first_impression
      dates = first_impression.created_at.to_date..last_impression.created_at.to_date
      if dates.first == dates.last
        dates = (first_impression.created_at.to_date - 1.day)..last_impression.created_at.to_date
      end
      @data = [['Date', '# of impressions']]

      dates.each do |d|
        @data.push [ d.to_time.to_formatted_s(:readable_dateonly), @project.impressions.where(created_at: d.beginning_of_day..d.end_of_day).count ]
      end
    end
  end

  def response_field
    @response_field = @project.response_fields.find(params[:response_field_id])

    if @response_field.bid_responses.order("sortable_value DESC").first
      @data = [['Price Range', '# of bids']]
      max = @response_field.bid_responses.order("sortable_value DESC").first.value.to_i.round(-3)
      interval = max / 8

      ranges = []
      counter = 0
      8.times do |i|
        next_counter = (counter + interval)
        ranges.push counter...next_counter
        counter = next_counter
      end

      ranges.each do |range|
        @data.push [
          "$#{range.first} to #{range.last}",
          @project.bids.submitted.includes(:bid_responses).select { |bid|
            range.cover? bid.bid_responses.where(response_field_id: @response_field.id).first.value.to_f
          }.length
        ]
      end
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end
end
