ProcureIo.Backbone.ProjectPageSubviews = []

ProcureIo.Backbone.ProjectPageSubviews.push Backbone.View.extend
  el: "#project-rss-links"

  initialize: ->
    @listenTo @options.parentView.router.filterOptions, "change", @render

  render: ->
    @$el.html JST['project/rss_links']
      parentView: @options.parentView

ProcureIo.Backbone.ProjectPageSubviews.push Backbone.View.extend
  el: "#sort-wrapper"

  initialize: ->
    @sortOptions = [
      key: "posted_at"
      label: "Posted At"
    ,
      key: "bids_due_at"
      label: "Bids Due"
    ]

    @listenTo @options.parentView.router.filterOptions, "change", @render

  render: ->
    @$el.html JST['shared/list_sorters']
      parentView: @options.parentView
      sortOptions: @sortOptions

ProcureIo.Backbone.ProjectView = Backbone.View.extend
  className: "project"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render

  render: ->
    @$el.html JST['project/project']
      project: @model
      parentView: @options.parentView

    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.ProjectPage = Backbone.View.extend

  el: "#project-page"

  initialize: ->
    @collection = new ProcureIo.Backbone.Collection
      url: '/projects.json'

    @collection.bind 'add', @addOne, @
    @collection.bind 'reset', @reset, @
    @collection.bind 'reset', @removeLoadingSpinner, @
    @collection.bind 'reset', @renderPagination, @

    @router = new ProcureIo.Backbone.SearchRouter @collection,
      sort: "posted_at"

    @allCategories = @options.allCategories

    @render()

    for subview in _.union ProcureIo.Backbone.ProjectPageSubviews, ProcureIo.Backbone.PaginationView
      new subview({parentView: @}).render()

    Backbone.history.start
      pushState: true

  submitSearch: (e) ->
    @router.navigate @router.filteredHref({page: 1}), {trigger: true}

  updateFilter: ProcureIo.Backbone.Mixins.updateFilter

  reset: ->
    $("#projects-wrapper").html('')
    @addAll()

    @$el.find(".no-projects")[if @collection.models.length == 0 then 'show' else 'hide']()

  render: ->
    @$el.html JST['project/page']({allCategories: @allCategories})
    rivets.bind(@$el, {filterOptions: @router.filterOptions})
    return @

  addOne: (bid) ->
    view = new ProcureIo.Backbone.ProjectView({model: bid, parentView: @})
    $("#projects-wrapper").append(view.render().el)

  addAll: ->
    @collection.each @addOne, @

  updateFilterFromForm: (e) ->
    @router.navigate @filteredHref({page: 1}), {trigger: true}
    e.preventDefault()

  removeLoadingSpinner: ->
    $("#project-page").removeClass 'loading'

  saveSearch: (e, $el, params) ->
    $el.button 'loading'

    $.ajax
      url: "/saved_searches.json"
      type: "POST"
      dataType: "json"
      data:
        saved_search:
          search_parameters: _.pick(@router.filterOptions.attributes, 'category', 'q') || {}

      success: ->
        $el.button 'reset'
        $el.flash_button false, "Search Saved!"
