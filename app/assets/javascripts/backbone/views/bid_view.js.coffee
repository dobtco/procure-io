ProcureIo.Backbone.BidPageView = Backbone.View.extend
  el: "#bid-page"

  initialize: ->
    @$el = @options.el if @options.el?
    @bid = @options.bid || new ProcureIo.Backbone.Bid(@options.bootstrapData)
    @bid.url = "/projects/#{@options.project.id}/bids/#{@bid.id}.json"

    @getLabel = (label_id) =>
      _.find @options.project.labels, (label) ->
        label.id == label_id

    @listenTo @bid,  "change", @render

    @getResponseField = (response_field_id) =>
      _.find @options.project.response_fields, (response_field) ->
        response_field.id == response_field_id

    @render()

  render: ->
    @$el.html JST['bid/bid']
      project: @options.project
      bid: @bid
      projectLabels: @options.project.labels
      getResponseField: @getResponseField
      getLabel: @getLabel
      abilities: @options.abilities

    @$el.find(".rating-select").raty
      score: ->
        $(@).attr('data-score')
      click: (score) =>
        @bid.set('rating', score)
        @bid.save()

    return @

  toggleStarred: ->
    @bid.set 'starred', (if @bid.get('starred') then false else true)
    @bid.save()

  toggleRead: ->
    @bid.set 'read', (if @bid.get('read') then false else true)
    @bid.save()

  undismissBid: ->
    @bid.save { dismissed_at: false }

  dismissCheckedBids: (e, $el) ->
    @bid.save
      dismissed_at: true
      dismissal_message: $el.find(".js-dismissal-message").val()
      show_dismissal_message_to_vendor: $el.find(".js-show-dismissal-message-to-vendor").is(":checked")

  unawardBid: ->
    @bid.save { awarded_at: false }

  awardCheckedBids: (e, $el) ->
    @bid.save
      awarded_at: true
      award_message: $el.find(".js-award-message").val()

  toggleLabeled: (e, $el, label_id) ->
    existingLabels = @bid.get('labels')

    if existingLabels.indexOf(label_id) != -1
      existingLabels = _.without existingLabels, label_id
    else
      existingLabels.push label_id

    @bid.set('labels', existingLabels)
    @bid.save(null, {silent: true}) # silent prevents a re-render when labels get alphabetized server-side

ProcureIo.Backbone.BidPageReviewsView = Backbone.View.extend
  el: "#bid-page-reviews"

  initialize: ->
    @$el = @options.el if @options.el?
    @bidReviews = @options.bootstrapData

    if !@options.bootstrapData
      $.getJSON "/projects/#{@options.project_id}/bids/#{@options.bid_id}/reviews", (data) =>
        @bidReviews = data
        @render()

    @render()

  render: ->
    @$el.html JST['bid/reviews']
      bidReviews: @bidReviews

    return @
