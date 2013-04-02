ProcureIo.PageSpecificScripts["reports#response_field"] = ->

  graph = new Rickshaw.Graph
    element: $("#chart")[0]
    renderer: "bar"
    height: 250
    series: [
      color: 'steelblue'
      data: ProcureIo.chartData
      name: "Bids per day"
    ]

  y_axis = new Rickshaw.Graph.Axis.Y
    graph: graph,
    orientation: 'left'
    element: $("#y-axis")[0]

  xAxis = new Rickshaw.Graph.Axis.X
    graph: graph

  xAxis.render()

  # hoverDetail = new Rickshaw.Graph.HoverDetail
  #   graph: graph
  #   yFormatter: (y) ->
  #     parseInt(y, 10)

  #   xFormatter: (x) ->
  #     moment.unix(x).format('M/D/YY')

  graph.render()
