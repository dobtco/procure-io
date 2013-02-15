ProcureIo.Backbone.BidPageView = Backbone.View.extend

  el: "#bid-page"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"
    "click [data-backbone-dismiss]": "toggleDismissed"
    "click [data-backbone-award]": "toggleAwarded"

  initialize: ->
    @bid = new ProcureIo.Backbone.Bid(@options.bootstrapData)
    @bid.url = "/projects/#{@options.projectId}/bids/#{@bid.id}.json"
    @bid.bind "change", @render, @
    @render()

  render: ->
    @$el.html JST['bid/bid'](@bid.toJSON())
    # rivets.bind(@$el, {})
    return @

  toggleStarred: ->
    @bid.set 'my_bid_review.starred', (if @bid.get('my_bid_review.starred') then false else true)
    @bid.save()

  toggleRead: ->
    @bid.set 'my_bid_review.read', (if @bid.get('my_bid_review.read') then false else true)
    @bid.save()

  toggleDismissed: ->
    if @bid.get('awarded_at') && !@bid.get('dismissed_at') then @bid.set('awarded_at', false)
    @bid.set 'dismissed_at', (if @bid.get('dismissed_at') then false else true)
    @bid.save()

  toggleAwarded: ->
    if @bid.get('dismissed_at') && !@bid.get('awarded_at') then @bid.set('dismissed_at', false)
    @bid.set 'awarded_at', (if @bid.get('awarded_at') then false else true)
    @bid.save()
