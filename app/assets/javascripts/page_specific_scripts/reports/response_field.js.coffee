ProcureIo.PageSpecificScripts["reports#response_field"] = ->

  return unless ProcureIo.chartData?

  $.getScript "https://www.google.com/jsapi", ->
    google.load "visualization", "1",
      packages:["corechart"]
      callback: ->
        data = google.visualization.arrayToDataTable ProcureIo.chartData

        options =
          chartArea:
            width: '90%'
            height: '70%'
          legend:
            position: 'bottom'

        chart = new google.visualization.PieChart(document.getElementById('chart'))
        chart.draw(data, options)
