#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

ProcureIo.Backbone =
  DEFAULT_LABEL_COLOR: "898989"

Backbone.Model.prototype.url = ->
    base = _.result(@, 'urlRoot') || _.result(@collection, 'baseUrl') || _.result(@collection, 'url')
    return base if this.isNew()
    pieces = base.split('?')
    pieces[0] + (if base.charAt(base.length - 1) == '/' then '' else '/') + encodeURIComponent(@id) + ".json" + (if pieces[1]? then "?#{pieces[1]}" else "")

Backbone.Collection.prototype.parse = (resp, xhr) ->
  @meta = resp.meta
  resp.results

Backbone.View.prototype.extendEvents = (newEvents) ->
  _.extend @events, newEvents