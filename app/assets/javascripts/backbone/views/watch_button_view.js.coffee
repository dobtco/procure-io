ProcureIo.Backbone.WatchButton = Backbone.View.extend
  el: ".watch-button-wrapper"

  events:
    "click a": "setWatching"

  initialize: ->
    @watching = @options.watching
    @render()

  render: ->
    @$el.html JST['shared/watch_button']
      watching: @watching
      description: @options.description

  setWatching: (e) ->
    if $(e.target).closest("a").hasClass('js-yes') && !@watching
      @updateWatching(true)

    else if $(e.target).closest("a").hasClass('js-no') && @watching
      @updateWatching(false)

  updateWatching: (true_or_false) ->
    @watching = true_or_false

    $.ajax
      url: "/watches/#{@options.watchable_type}/#{@options.watchable_id}"
      method: "post"

    @render()
