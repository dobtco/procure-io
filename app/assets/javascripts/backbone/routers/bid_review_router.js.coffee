# @todo weird back button bug
ProcureIo.Backbone.BidReviewRouter = Backbone.Router.extend
  routes:
    'projects/:id/bids': 'reviewBids'
    'projects/:id/bids?*params': 'reviewBids'

  initialize: ->
    @filterOptions = new Backbone.Model
      "f1": "all"
      "f2": "open"

  reviewBids: (id, params) ->
    params = $.urlParams()
    if _.isEmpty(params) then @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}"
    @filterOptions.set "f1", params?.f1
    @filterOptions.set "f2", params?.f2
    ProcureIo.Backbone.Bids.fetch({data: @filterOptions.toJSON()})
