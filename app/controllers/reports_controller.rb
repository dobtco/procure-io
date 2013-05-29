class ReportsController < ApplicationController
  # Load
  load_resource :project

  # Authorize
  before_filter { |c| c.authorize! :see_stats, @project }

  def bids_over_time
    dates = @project.posted_at.to_date..(@project.bids_due_at ? [Time.now, @project.bids_due_at].min : Time.now).to_date
    bids = @project.bids.submitted
    @data = [[t('g.date'), t('g.number_of_bids')]]

    dates.each do |d|
      @data.push [ d.to_time.to_formatted_s(:readable_dateonly), bids.select { |b| b.submitted_at.to_date == d }.length ]
    end

    @report_title = t('g.bids_over_time')
    render "reports/common"
  end

  def impressions
    @data = [[t('g.date'), t('g.impressions'), t('g.unique_impressions')]]
    uniques = @project.impressions.select("DISTINCT(impressions.ip_address)").group("impressions.created_at::date").count

    @project.impressions.group("impressions.created_at::date").order("impressions.created_at::date").count.each do |date, count|
      @data.push [date, count, uniques[date]]
    end

    @report_title = t('g.impressions')
    render "reports/common"
  end

  def response_field
    @response_field = @project.response_fields.find(params[:response_field_id])

    if @response_field.responses.order("sortable_value DESC").first
      @data = [[t('g.price_range'), t('g.number_of_bids')]]
      max = @response_field.responses.order("sortable_value DESC").first.value.to_i.round(-3)
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
          t('g.x_to_x', first: range.first, last: range.last),
          @project.bids.submitted.includes(:responses).select { |bid|
            range.cover? bid.responses.where(response_field_id: @response_field.id).first.value.to_f
          }.length
        ]
      end
    end

    @report_title = @response_field.label
    render "reports/common"
  end
end
