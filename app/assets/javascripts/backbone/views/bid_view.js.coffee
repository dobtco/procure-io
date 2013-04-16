ProcureIo.Backbone.BidPageView = Backbone.View.extend

  el: "#bid-page"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"
    "click [data-backbone-dismiss]": "toggleDismissed"
    "click [data-backbone-award]": "toggleAwarded"
    "click [data-backbone-label]": "toggleLabeled"
    "click [data-backbone-watch]": "toggleWatching"

  initialize: ->
    @$el = @options.el if @options.el?
    @bid = @options.bid || new ProcureIo.Backbone.Bid(@options.bootstrapData)
    @bid.url = "/projects/#{@options.project.id}/bids/#{@bid.id}.json"
    @listenTo @bid,  "change", @render
    @render()

  render: ->
    @$el.html JST['bid/bid']
      project: @options.project
      bid: @bid.toJSON()
      projectLabels: @options.project.labels
      existingLabels: _.map(@bid.get('labels'), (l) -> l.name)

    rivets.bind(@$el, {bid: @bid})

    @$el.find(".rating-select").raty
      score: ->
        $(@).attr('data-score')
      click: (score) =>
        @bid.set('my_bid_review.rating', score)
        @bid.save()

    @$el.find("[data-toggle=tooltip]").tooltip()

    @$el.find(".rating-select").on "change", =>
      @bid.save()

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

  toggleWatching: ->
    @bid.set 'watching', (if @bid.get('watching') then false else true)
    @bid.save()

  toggleLabeled: (e) ->
    existingLabels = _.map @bid.get('labels'), (l) ->
      l.name

    name = $(e.target).data('backbone-label')
    labels = @bid.get('labels')

    if existingLabels.indexOf(name) != -1
      labels.splice(existingLabels.indexOf(name), 1)
    else
      labels.push {name: name, color: $(e.target).data('backbone-label-color')}

    @bid.set('labels', labels)
    @bid.save()
