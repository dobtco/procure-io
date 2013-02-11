ProcureIo.Backbone.BidPageView = Backbone.View.extend

  el: "#bid-page"

  # events:

  initialize: ->
    @bid = new ProcureIo.Backbone.Bid(@options.bootstrapData)
    @render()


  render: ->
    @$el.html JST['bid/bid'](@bid.toJSON())
    rivets.bind(@$el, {})
    return @


  # toggleStarred: ->
  #   @model.set 'my_bid_review.starred', (if @model.get('my_bid_review.starred') then false else true)
  #   @model.save()

  # toggleRead: ->
  #   @model.set 'my_bid_review.read', (if @model.get('my_bid_review.read') then false else true)
  #   @model.save()

