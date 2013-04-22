ProcureIo.Backbone.BidList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Bid
  parse: ProcureIo.Backbone.Overrides.parse