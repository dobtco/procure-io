ProcureIo.Backbone.WatchButton = Backbone.View.extend
  events:
    "click a": "setWatching"

  initialize: ->
    @$el = $(".#{@options.watchable_type}-watch-button")
    @watching = @options.watching
    @render()

  render: ->
    @$el.html JST['shared/watch_button']
      watching: @watching
      description: @options.description
      modelName: @options.watchable_type

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

ProcureIo.Backbone.WatchButtonHelper = (className, watchable, opts = {}) ->
  """
    <span class="#{className}-watch-button watch-button #{opts.class}">
      <script>
        new ProcureIo.Backbone.WatchButton({
          watchable_type: '#{className}',
          watchable_id: "#{watchable.get('id')}",
          watching: #{watchable.get('watching')},
          description: "#{opts.tooltip || I18n.t('tooltips.watch_' + className)}"
        });
      </script>
    </span>
  """
