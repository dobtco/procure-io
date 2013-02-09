ProcureIo.Backbone.BidReviewRouter = Backbone.Router.extend
  routes:
    'projects/:id/bids': 'reviewBids'
    'projects/:id/bids?*params': 'reviewBids'

  reviewBids: (id, params) ->
    # @pageOptions.set "activeFilter", params.f1 || 'allBids'
    # @pageOptions.set "activeSubfilter", params.f2 || 'openBids'
    ProcureIo.Backbone.Bids.fetch()
