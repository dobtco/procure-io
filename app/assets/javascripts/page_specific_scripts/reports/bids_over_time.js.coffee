ProcureIo.PageSpecificScripts["reports#bids_over_time"] = ->

  graph = new Rickshaw.Graph
    element: $("#chart")[0]
    renderer: "line"
    interpolation: 'linear'
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

  hoverDetail = new Rickshaw.Graph.HoverDetail
    graph: graph
    yFormatter: (y) ->
      parseInt(y, 10)

    xFormatter: (x) ->
      moment.unix(x).format('M/D/YY')

  graph.render()
