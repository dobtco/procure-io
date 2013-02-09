# @todo clear backbone views when navigating with turbolinks?

ProcureIo.Backbone.BidReviewSidebarFilterView = Backbone.View.extend
  el: "#sidebar-filter-wrapper"

  initialize: ->
    @projectId = @options.projectId
    @filteredHref = @options.filteredHref
    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['bid_review/sidebar_filter']({filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @filteredHref})

ProcureIo.Backbone.BidReviewTopFilterView = Backbone.View.extend
  el: "#top-filter-wrapper"

  initialize: ->
    @projectId = @options.projectId
    @filteredHref = @options.filteredHref
    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['bid_review/top_filter']({filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @filteredHref})


ProcureIo.Backbone.BidReviewView = Backbone.View.extend
  tagName: "tbody"
  className: "bid-tbody"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "destroy", @remove, @
    @model.bind "change", @render, @

  render: ->

    getValue = (id) =>
      response = _.find @model.get('bid_responses'), (bidResponse) ->
        bidResponse.response_field_id is id

      response.value

    @$el.html JST['bid_review/bid'](_.extend(@model.toJSON(), {pageOptions: @parentView.pageOptions, getValue: getValue}))

    return @

  clear: ->
    @model.destroy()

  toggleStarred: ->
    @model.set 'my_bid_review.starred', (if @model.get('my_bid_review.starred') then false else true)
    @model.save()

  toggleRead: ->
    @model.set 'my_bid_review.read', (if @model.get('my_bid_review.read') then false else true)
    @model.save()


ProcureIo.Backbone.BidReviewPage = Backbone.View.extend

  el: "#bid-review-page"

  events:
    "click [data-backbone-updatefilter]": "updateFilter"

  initialize: ->
    ProcureIo.Backbone.Bids = new ProcureIo.Backbone.BidList()
    ProcureIo.Backbone.Bids.url = "/projects/#{@options.projectId}/bids"

    ProcureIo.Backbone.Bids.bind 'add', @addOne, @
    ProcureIo.Backbone.Bids.bind 'reset', @reset, @

    @pageOptions = new Backbone.Model
      keyFields: @options.keyFields

    @filteredHref = (k, v) =>
      existingParams = ProcureIo.Backbone.router.filterOptions.toJSON()
      existingParams[k] = v

      newParams = {}
      hasParams = false

      _.each existingParams, (val, key) ->
        if val
          hasParams = true
          newParams[key] = val

      if hasParams
        "/projects/#{@options.projectId}/bids?#{$.param(newParams)}"
      else
        "/projects/#{@options.projectId}/bids"


    ProcureIo.Backbone.router = new ProcureIo.Backbone.BidReviewRouter()

    @render()

    new ProcureIo.Backbone.BidReviewSidebarFilterView({projectId: @options.projectId, filteredHref: @filteredHref})
    new ProcureIo.Backbone.BidReviewTopFilterView({projectId: @options.projectId, filteredHref: @filteredHref})

    Backbone.history.start
      pushState: true

  reset: ->
    $(".bid-tbody").remove()
    @addAll()

  render: ->
    @$el.html JST['bid_review/page'](@pageOptions.toJSON())
    rivets.bind(@$el, {pageOptions: @pageOptions, filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  addOne: (bid) ->
    view = new ProcureIo.Backbone.BidReviewView({model: bid, parentView: @})
    $("#bids-table").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Bids.each @addOne, @

  updateFilter: (e) ->
    return if e.metaKey
    ProcureIo.Backbone.router.navigate $(e.target).attr('href'), {trigger: true}
    e.preventDefault()
