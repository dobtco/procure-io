ProcureIo.Backbone.SearchableTableSubviews = []

ProcureIo.Backbone.SearchableTableSubviews.push Backbone.View.extend
  el: ".searchable-table-thead"

  initialize: ->
    @listenTo @options.parentView.router.filterOptions, 'change', @render

  render: ->
    @$el.html JST['shared/searchable_table_thead']
      parentView: @options.parentView

    return @

ProcureIo.Backbone.SearchableTableSubviews.push ProcureIo.Backbone.PaginationView

ProcureIo.Backbone.SearchableTableItemView = Backbone.View.extend
  tagName: "tr"

  render: ->
    @$el.html JST['shared/searchable_table_item']
      parentView: @options.parentView
      model: @model

    @$el.find("[data-toggle=tooltip]").tooltip()

    return @

ProcureIo.Backbone.SearchableTable = Backbone.View.extend
  el: "#searchable-table-page"

  initialize: ->
    defaultColumn = _.find @options.columns, (c) -> c.defaultSort?

    if @options.collection instanceof Backbone.Collection
      @collection = @options.collection
    else
      @collection = new @options.collection(@options.collectionOptions || {})

    @collection.bind 'reset', @reset, @
    @collection.bind 'reset', @removeLoadingSpinner, @
    @collection.bind 'reset', @renderSubviews, @

    @router = new ProcureIo.Backbone.SearchRouter @collection,
      sort: defaultColumn.sortKey
      direction: defaultColumn.defaultSort

    @render()

    for subview in ProcureIo.Backbone.SearchableTableSubviews
      new subview({parentView: @}).render()

    if @options.bootstrapData
      @router.setParamsFromUrl()
      @collection.reset(@options.bootstrapData, {parse: true})
      bootstrapped = true

    Backbone.history.start
      pushState: true
      silent: bootstrapped?

  render: ->
    @$el.html JST['shared/searchable_table']
      options: @options

    rivets.bind @$el,
      filterOptions: @router.filterOptions

  updateFilter: ProcureIo.Backbone.Mixins.updateFilter

  reset: ->
    $(".searchable-table-tbody").html('')
    @addAll()
    $(".searchable-table-empty")[if @collection.models.length > 0 then 'hide' else 'show']()

  addAll: ->
    @collection.each @addOne, @

  addOne: (model) ->
    view = new ProcureIo.Backbone.SearchableTableItemView({model: model, parentView: @})
    $(".searchable-table-tbody").append(view.render().el)

  removeLoadingSpinner: ->
    $(".search-page").removeClass 'loading'

  submitSearch: (e) ->
    @router.navigate @router.filteredHref({page: 1}), {trigger: true}
