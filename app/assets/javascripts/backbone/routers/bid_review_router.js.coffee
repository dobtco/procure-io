ProcureIo.Backbone.BidReviewRouter = Backbone.Router.extend
  routes:
    'projects/:id/bids': 'reviewBids'

  initialize: ->
    @filterOptions = new Backbone.Model
      "f1": undefined
      "f2": undefined

      filteredHref: (key, val) ->
        console.log key, val
        "a"
        # currentParams = ProcureIo.Backbone.router.filterOptions.toJSON()
        # currentParams[key] = val
        # console.log currentParams
        # "#{ProcureIo.Backbone.Bids.url}?#{key}=#{val}"


  reviewBids: (id, params) ->
    console.log params
    @filterOptions.set "f1", params?.f1
    @filterOptions.set "f2", params?.f2
    ProcureIo.Backbone.Bids.fetch()
