ProcureIo.Backbone.SearchableTablePaginationView = Backbone.View.extend
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

  render: ->
    @$el.html JST['shared/searchable_table_pagination']
      meta: @options.parentView.collection.meta
      pages: @getPagesArray(@options.parentView.collection.meta)
      router: @options.parentView.router

ProcureIo.Backbone.SearchableTableTheadView = Backbone.View.extend
  el: ".searchable-table-thead"

  render: ->
    @$el.html JST['shared/searchable_table_thead']
      parentView: @options.parentView

    return @

ProcureIo.Backbone.SearchableTableItemView = Backbone.View.extend
  tagName: "tr"

  render: ->
    @$el.html JST['shared/searchable_table_item']
      parentView: @options.parentView
      model: @model

    return @

ProcureIo.Backbone.SearchableTable = Backbone.View.extend
  el: "#searchable-table-page"

  events:
    "submit #filter-form": "updateFilterFromForm"
    "click [data-backbone-updatefilter]": "updateFilter"

  initialize: ->
    @subviews = {}
    defaultColumn = _.find @options.columns, (c) -> c.defaultSort?

    @collection = new @options.collection

    @collection.bind 'reset', @reset, @
    @collection.bind 'reset', @removeLoadingSpinner, @
    @collection.bind 'reset', @renderSubviews, @

    @router = new ProcureIo.Backbone.SearchRouter @collection,
      sort: defaultColumn.sortKey
      direction: defaultColumn.defaultSort

    @render()

    Backbone.history.start
      pushState: true

  render: ->
    @$el.html JST['shared/searchable_table']
      options: @options

    rivets.bind @$el,
      filterOptions: @router.filterOptions

  updateFilterFromForm: (e) ->
    @router.navigate @router.filteredHref({page: 1}), {trigger: true}
    e.preventDefault()

  updateFilter: (e) ->
    return if e.metaKey
    @router.navigate $(e.target).attr('href'), {trigger: true}
    e.preventDefault()

  renderSubviews: ->
    (@subviews['pagination'] ||= new ProcureIo.Backbone.SearchableTablePaginationView
      parentView: @
    ).render()

    (@subviews['thead'] ||= new ProcureIo.Backbone.SearchableTableTheadView
      parentView: @
    ).render()

  reset: ->
    $(".searchable-table-tbody").html('')
    @addAll()

  addAll: ->
    @collection.each @addOne, @

  addOne: (model) ->
    view = new ProcureIo.Backbone.SearchableTableItemView({model: model, parentView: @})
    $(".searchable-table-tbody").append(view.render().el)

  removeLoadingSpinner: ->
    $(".search-page").removeClass 'loading'

