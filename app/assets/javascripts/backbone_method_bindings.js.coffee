_.extend Backbone.View.prototype,
  onClick: (e) ->
    return if $(e.currentTarget).hasClass 'disabled'
    @[$(e.currentTarget).data('backbone-click')]?(e, $(e.currentTarget), $(e.currentTarget).data('backbone-params'))

  onSubmit: (e) ->
    @[$(e.currentTarget).data('backbone-submit')]?(e, $(e.currentTarget), $(e.currentTarget).data('backbone-params'))

  delegateEvents: (events) ->
    delegateEventSplitter = /^(\S+)\s*(.*)$/

    events ||= _.result(this, "events") || {}

    _.extend events,
      "click [data-backbone-click]": "onClick"
      "submit [data-backbone-submit]": "onSubmit"

    @undelegateEvents()

    for key of events
      method = events[key]
      method = this[events[key]]  unless _.isFunction(method)
      throw new Error("Method \"" + events[key] + "\" does not exist")  unless method
      match = key.match(delegateEventSplitter)
      eventName = match[1]
      selector = match[2]
      method = _.bind(method, this)
      eventName += ".delegateEvents" + @cid
      if selector is ""
        @$el.on eventName, method
      else
        @$el.on eventName, selector, method
