# ProcureIo.Backbone.ProjectPaginationView = Backbone.View.extend
#   el: "#pagination-wrapper"

#   pushIfDoesntExist: (page, pagesArray, lastPage) ->
#     pagesArray.push page unless (pagesArray.indexOf(page) > -1) or (page < 1) or (page > lastPage)

#   getPagesArray: (meta) ->
#     if meta.last_page is 1 then return [1]

#     pagesArray = [1, 2]
#     @pushIfDoesntExist(meta.last_page, pagesArray, meta.last_page)
#     @pushIfDoesntExist(meta.last_page - 1, pagesArray, meta.last_page)

#     offset = 0
#     currentPage = meta.page
#     while pagesArray.length < 11 and (currentPage - offset >= 1 or currentPage + offset <= meta.last_page)
#       @pushIfDoesntExist(currentPage - offset, pagesArray, meta.last_page)
#       @pushIfDoesntExist(currentPage + offset, pagesArray, meta.last_page)
#       offset++

#     pagesArray = _.sortBy pagesArray, (p) -> p

#     pagesArrayWithBreak = []
#     _.each pagesArray, (p, index) ->
#       if pagesArray[index - 1]? and p - pagesArray[index - 1] > 1
#         pagesArrayWithBreak.push "break"

#       pagesArrayWithBreak.push p

#     pagesArrayWithBreak

#   initialize: ->
#     @filteredHref = @options.filteredHref

#   render: ->
#     @$el.html JST['project/pagination']({meta: ProcureIo.Backbone.Bids.meta, pages: @getPagesArray(ProcureIo.Backbone.Bids.meta), filteredHref: @filteredHref})


ProcureIo.Backbone.ProjectView = Backbone.View.extend
  # events:
  className: "project"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "destroy", @remove, @
    @model.bind "change", @render, @

  render: ->
    @$el.html JST['project/project'](@model.toJSON())
    rivets.bind(@$el, {project: @model})
    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.ProjectPage = Backbone.View.extend

  el: "#project-page"

  # events:
  #   "click .sort-wrapper a": "updateFilter"
  #   "click [data-backbone-updatefilter]": "updateFilter"
  #   "click [data-backbone-dismiss]:not(.disabled)": "dismissCheckedBids"
  #   "click [data-backbone-award]:not(.disabled)": "awardCheckedBids"

  initialize: ->
    ProcureIo.Backbone.Projects = new ProcureIo.Backbone.ProjectList()
    ProcureIo.Backbone.Projects.baseUrl = "/projects"
    ProcureIo.Backbone.Projects.url = "#{ProcureIo.Backbone.Projects.baseUrl}.json"

    ProcureIo.Backbone.Projects.bind 'add', @addOne, @
    ProcureIo.Backbone.Projects.bind 'reset', @reset, @
    # ProcureIo.Backbone.Projects.bind 'reset', @removeLoadingSpinner, @
    # ProcureIo.Backbone.Projects.bind 'reset', @renderPagination, @

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


    ProcureIo.Backbone.router = new ProcureIo.Backbone.ProjectRouter()

    @render()

    @sidebarFilterView = new ProcureIo.Backbone.BidReviewSidebarFilterView({projectId: @options.projectId, filteredHref: @filteredHref})
    @topFilterView = new ProcureIo.Backbone.BidReviewTopFilterView({projectId: @options.projectId, filteredHref: @filteredHref})

    Backbone.history.start
      pushState: true

  reset: ->
    $("#projects-wrapper").html('')
    @addAll()

  render: ->
    @$el.html JST['project/page']()
    # rivets.bind(@$el, {filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  # renderPagination: ->
  #   @paginationView ||= new ProcureIo.Backbone.BidReviewPaginationView({filteredHref: @filteredHref})
  #   @paginationView.render()

  addOne: (bid) ->
    view = new ProcureIo.Backbone.ProjectView({model: bid, parentView: @})
    $("#projects-wrapper").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Projects.each @addOne, @

  # removeLoadingSpinner: ->
  #   $("#bid-review-page").removeClass 'loading'

  # refetch: ->
  #   $("#bid-review-page").addClass 'loading'
  #   ProcureIo.Backbone.Projects.fetch {data: ProcureIo.Backbone.router.filterOptions.toJSON()}
