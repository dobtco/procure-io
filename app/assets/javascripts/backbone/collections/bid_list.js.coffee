ProcureIo.Backbone.BidList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Bid
  parse: (resp, xhr) ->
    @meta = resp.meta
    resp.results
