# @todo clear backbone views when navigating with turbolinks?

ProcureIo.Backbone.BidReviewPaginationView = Backbone.View.extend
  el: "#pagination-wrapper"

  pushIfDoesntExist: (page, pagesArray, lastPage) ->
    pagesArray.push page unless (pagesArray.indexOf(page) > -1) or (page < 1) or (page > lastPage)

  getPagesArray: (meta) ->
    if meta.last_page is 1 then return [1]

    pagesArray = [1, 2]
    @pushIfDoesntExist(meta.last_page, pagesArray, meta.last_page)
    @pushIfDoesntExist(meta.last_page - 1, pagesArray, meta.last_page)

    offset = 0
    currentPage = meta.page
    while pagesArray.length < 11 and (currentPage - offset >= 1 or currentPage + offset <= meta.last_page)
      @pushIfDoesntExist(currentPage - offset, pagesArray, meta.last_page)
      @pushIfDoesntExist(currentPage + offset, pagesArray, meta.last_page)
      offset++

    pagesArray = _.sortBy pagesArray, (p) -> p

    pagesArrayWithBreak = []
    _.each pagesArray, (p, index) ->
      if pagesArray[index - 1]? and p - pagesArray[index - 1] > 1
        pagesArrayWithBreak.push "break"

      pagesArrayWithBreak.push p

    pagesArrayWithBreak

  initialize: ->
    @filteredHref = @options.filteredHref

  render: ->
    @$el.html JST['bid_review/pagination']({meta: ProcureIo.Backbone.Bids.meta, pages: @getPagesArray(ProcureIo.Backbone.Bids.meta), filteredHref: @filteredHref})

ProcureIo.Backbone.BidReviewActionsView = Backbone.View.extend
  el: "#actions-wrapper"

  render: ->
    bidsChecked = ProcureIo.Backbone.Bids.find (b) -> b.attributes.checked
    @$el.html JST['bid_review/actions']({bidsChecked: bidsChecked, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()})

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
  tagName: "tr"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "destroy", @remove, @
    @model.bind "change", @render, @
    @model.bind "change:checked", @parentView.renderActions, @

  render: ->

    # @todo this could cause some terrible recursion
    if ProcureIo.Backbone.router.filterOptions.get("f1") is "starred" and @model.get("total_stars") < 1
      @parentView.refetch()

    getValue = (id) =>
      response = _.find @model.get('bid_responses'), (bidResponse) ->
        bidResponse.response_field_id is id

      if response then response.value else ""

    @$el.html JST['bid_review/bid'](_.extend(@model.toJSON(), {pageOptions: @parentView.pageOptions, getValue: getValue}))
    rivets.bind(@$el, {bid: @model})

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
    "click .sort-wrapper a": "updateFilter"
    "click [data-backbone-updatefilter]": "updateFilter"
    "click [data-backbone-dismiss]:not(.disabled)": "dismissCheckedBids"
    "click [data-backbone-award]:not(.disabled)": "awardCheckedBids"

  initialize: ->
    ProcureIo.Backbone.Bids = new ProcureIo.Backbone.BidList()
    ProcureIo.Backbone.Bids.baseUrl = "/projects/#{@options.projectId}/bids"
    ProcureIo.Backbone.Bids.url = "#{ProcureIo.Backbone.Bids.baseUrl}.json"

    ProcureIo.Backbone.Bids.bind 'add', @addOne, @
    ProcureIo.Backbone.Bids.bind 'reset', @reset, @
    ProcureIo.Backbone.Bids.bind 'reset', @removeLoadingSpinner, @
    ProcureIo.Backbone.Bids.bind 'reset', @renderActions, @
    ProcureIo.Backbone.Bids.bind 'reset', @renderPagination, @

    @pageOptions = new Backbone.Model
      keyFields: @options.keyFields

    @filteredHref = (newFilters) =>
      existingParams = ProcureIo.Backbone.router.filterOptions.toJSON()

      for k, v of newFilters
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

    @sidebarFilterView = new ProcureIo.Backbone.BidReviewSidebarFilterView({projectId: @options.projectId, filteredHref: @filteredHref})
    @topFilterView = new ProcureIo.Backbone.BidReviewTopFilterView({projectId: @options.projectId, filteredHref: @filteredHref})

    Backbone.history.start
      pushState: true

  reset: ->
    $("#bids-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['bid_review/page'](@pageOptions.toJSON())
    rivets.bind(@$el, {pageOptions: @pageOptions, filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderActions: ->
    @actionsView ||= new ProcureIo.Backbone.BidReviewActionsView()
    @actionsView.render()

  renderPagination: ->
    @paginationView ||= new ProcureIo.Backbone.BidReviewPaginationView({filteredHref: @filteredHref})
    @paginationView.render()

  addOne: (bid) ->
    view = new ProcureIo.Backbone.BidReviewView({model: bid, parentView: @})
    $("#bids-tbody").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Bids.each @addOne, @

  updateFilter: (e) ->
    return if e.metaKey
    ProcureIo.Backbone.router.navigate $(e.target).attr('href'), {trigger: true}
    e.preventDefault()

  dismissCheckedBids: ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id
    @sendBatchAction('dismiss', ids)

  awardCheckedBids: ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id
    @sendBatchAction('award', ids)

  sendBatchAction: (action, ids) ->
    $.ajax
      url: "#{ProcureIo.Backbone.Bids.baseUrl}/batch"
      type: "PUT"
      data:
        ids: ids
        bid_action: action
      success: =>
        @refetch()

  removeLoadingSpinner: ->
    $("#bid-review-page").removeClass 'loading'

  refetch: ->
    $("#bid-review-page").addClass 'loading'
    ProcureIo.Backbone.Bids.fetch {data: ProcureIo.Backbone.router.filterOptions.toJSON()}
