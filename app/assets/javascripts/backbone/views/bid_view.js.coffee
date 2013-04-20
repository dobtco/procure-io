ProcureIo.Backbone.BidPageView = Backbone.View.extend

  el: "#bid-page"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"
    "click [data-backbone-dismiss]": "toggleDismissed"
    "click [data-backbone-award]": "toggleAwarded"
    "click [data-backbone-label-id]": "toggleLabeled"
    "click [data-backbone-watch]": "toggleWatching"

  initialize: ->
    @$el = @options.el if @options.el?
    @bid = @options.bid || new ProcureIo.Backbone.Bid(@options.bootstrapData)
    @bid.url = "/projects/#{@options.project.id}/bids/#{@bid.id}.json"

    @getResponseField = (response_field_id) =>
      _.find @options.project.response_fields, (response_field) ->
        response_field.id == response_field_id

    @getLabel = (label_id) =>
      _.find @options.project.labels, (label) ->
        label.id == label_id

    @listenTo @bid,  "change", @render
    @render()

  render: ->
    @$el.html JST['bid/bid']
      project: @options.project
      bid: @bid.toJSON()
      projectLabels: @options.project.labels
      getResponseField: @getResponseField
      getLabel: @getLabel

    rivets.bind(@$el, {bid: @bid})

    @$el.find(".rating-select").raty
      score: ->
        $(@).attr('data-score')
      click: (score) =>
        @bid.set('rating', score)
        @bid.save()

    @$el.find("[data-toggle=tooltip]").tooltip()

    @$el.find(".rating-select").on "change", =>
      @bid.save()

    return @

  toggleStarred: ->
    @bid.set 'starred', (if @bid.get('starred') then false else true)
    @bid.save()

  toggleRead: ->
    @bid.set 'read', (if @bid.get('read') then false else true)
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
    labels = @bid.get('labels')
    label_id = $(e.target).data('backbone-label-id')

    if labels.indexOf(label_id) != -1
      labels = _.without labels, label_id
    else
      labels.push label_id

    @bid.set('labels', labels)
    @bid.save()
