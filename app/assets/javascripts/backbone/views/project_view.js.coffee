ProcureIo.Backbone.ProjectRssLinksView = Backbone.View.extend
  el: "#project-rss-links"

  initialize: ->
    @filteredHref = @options.filteredHref
    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['project/rss_links']({filteredHref: @filteredHref})

ProcureIo.Backbone.ProjectSortView = Backbone.View.extend
  el: "#sort-wrapper"

  initialize: ->
    @filteredHref = @options.filteredHref
    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['project/sort']({filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @filteredHref})


ProcureIo.Backbone.PaginationView = Backbone.View.extend
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
    @collection = @options.collection

  render: ->
    @$el.html JST['shared/pagination']({meta: @collection.meta, pages: @getPagesArray(@collection.meta), filteredHref: @filteredHref})


ProcureIo.Backbone.ProjectView = Backbone.View.extend
  # events:
  className: "project"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "destroy", @remove, @
    @model.bind "change", @render, @

  render: ->
    @$el.html JST['project/project'](_.extend(@model.toJSON(), {filteredHref: @parentView.filteredHref}))
    rivets.bind(@$el, {project: @model})
    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.ProjectPage = Backbone.View.extend

  el: "#project-page"

  events:
    "click .sort-wrapper a": "updateFilter"
    "submit #project-filter-form": "updateFilterFromForm"
    "click [data-backbone-updatefilter]": "updateFilter"
    "click #save-search-button": "saveSearch"

  initialize: ->
    ProcureIo.Backbone.Projects = new ProcureIo.Backbone.ProjectList()
    ProcureIo.Backbone.Projects.baseUrl = "/projects"
    ProcureIo.Backbone.Projects.url = "#{ProcureIo.Backbone.Projects.baseUrl}.json"

    ProcureIo.Backbone.Projects.bind 'add', @addOne, @
    ProcureIo.Backbone.Projects.bind 'reset', @reset, @
    ProcureIo.Backbone.Projects.bind 'reset', @removeLoadingSpinner, @
    ProcureIo.Backbone.Projects.bind 'reset', @renderPagination, @

    @filteredHref = (newFilters, format) =>
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
        "/projects#{if format? then '.'+format else ''}?#{$.param(newParams)}"
      else
        "/projects#{if format? then '.'+format else ''}"


    ProcureIo.Backbone.router = new ProcureIo.Backbone.ProjectRouter()

    @allCategories = @options.allCategories

    @render()

    @sortView = new ProcureIo.Backbone.ProjectSortView({filteredHref: @filteredHref})
    @rssLinksView = new ProcureIo.Backbone.ProjectRssLinksView({filteredHref: @filteredHref})

    Backbone.history.start
      pushState: true

  reset: ->
    $("#projects-wrapper").html('')
    @addAll()

  render: ->
    @$el.html JST['project/page']({allCategories: @allCategories})
    rivets.bind(@$el, {filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderPagination: ->
    @paginationView ||= new ProcureIo.Backbone.PaginationView({filteredHref: @filteredHref, collection: ProcureIo.Backbone.Projects})
    @paginationView.render()

  addOne: (bid) ->
    view = new ProcureIo.Backbone.ProjectView({model: bid, parentView: @})
    $("#projects-wrapper").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Projects.each @addOne, @

  updateFilterFromForm: (e) ->
    ProcureIo.Backbone.router.navigate @filteredHref({page: 1}), {trigger: true}
    e.preventDefault()

  updateFilter: (e) ->
    return if e.metaKey
    ProcureIo.Backbone.router.navigate $(e.target).attr('href'), {trigger: true}
    e.preventDefault()

  removeLoadingSpinner: ->
    $("#project-page").removeClass 'loading'

  saveSearch: (e) ->
    console.log _.pick(ProcureIo.Backbone.router.filterOptions.attributes, 'category', 'q')
    $(e.target).button 'loading'

    $.ajax
      url: "/saved_searches.json"
      type: "POST"
      dataType: "json"
      data:
        saved_search:
          search_parameters: _.pick(ProcureIo.Backbone.router.filterOptions.attributes, 'category', 'q') || {}

      success: ->
        $(e.target).button 'reset'
        $(e.target).flash_button false, "Search Saved!"
