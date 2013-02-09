ProcureIo.Backbone.BidReviewRouter = Backbone.Router.extend
  routes:
    'projects/:id/bids': 'reviewBids'
    'projects/:id/bids?*params': 'reviewBids'

  initialize: ->
    @filterOptions = new Backbone.Model
      "f1": undefined
      "f2": undefined

  reviewBids: (id, params) ->
    params = $.urlParams()
    console.log params
    @filterOptions.set "f1", params?.f1
    @filterOptions.set "f2", params?.f2
    ProcureIo.Backbone.Bids.fetch()
