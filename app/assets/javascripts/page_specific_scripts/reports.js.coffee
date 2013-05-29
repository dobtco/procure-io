ProcureIo.PageSpecificScripts["reports"] = ->
  switch $('body').data('action')
    when "bids_over_time", "impressions", "unique_impressions" then ProcureIo.chart 'LineChart'
    when "response_field" then ProcureIo.chart 'PieChart'
