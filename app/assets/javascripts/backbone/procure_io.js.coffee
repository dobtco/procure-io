#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

ProcureIo.Backbone = {
  views: {}
}

ProcureIo.Backbone.Overrides = {
  collectionUrl: ->
    base = _.result(@, 'urlRoot') || _.result(@collection, 'baseUrl') || urlError()
    return base if this.isNew()
    base + (if base.charAt(base.length - 1) == '/' then '' else '/') + encodeURIComponent(@id) + ".json"
}