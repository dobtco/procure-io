ProcureIo.Backbone.VendorSortView = Backbone.View.extend
  el: "#sort-wrapper"

  initialize: ->
    @filteredHref = @options.filteredHref
    @sortOptions = [
      key: "name"
      label: "Name"
    ]
    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['shared/sorters']({sortOptions: @sortOptions, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @filteredHref})

ProcureIo.Backbone.VendorView = Backbone.View.extend
  tagName: "tr"
  className: "vendor"

  initialize: ->
    @parentView = @options.parentView

  render: ->
    @$el.html JST['vendors_admin/vendor'](_.extend(@model.toJSON(), {filteredHref: @parentView.filteredHref}))
    return @

ProcureIo.Backbone.VendorsAdminPage = Backbone.View.extend

  el: "#vendors-admin-page"

  events:
    "click .sort-wrapper a": "updateFilter"
    "submit #vendor-filter-form": "updateFilterFromForm"
    "click [data-backbone-updatefilter]": "updateFilter"

  initialize: ->
    ProcureIo.Backbone.Vendors = new ProcureIo.Backbone.VendorList()
    ProcureIo.Backbone.Vendors.baseUrl = "/vendors"
    ProcureIo.Backbone.Vendors.url = "#{ProcureIo.Backbone.Vendors.baseUrl}.json"

    ProcureIo.Backbone.Vendors.bind 'reset', @reset, @
    ProcureIo.Backbone.Vendors.bind 'reset', @removeLoadingSpinner, @
    ProcureIo.Backbone.Vendors.bind 'reset', @renderPagination, @

    @filteredHref = (newFilters, format) =>
      existingParams = ProcureIo.Backbone.router.filterOptions.toJSON()

      for k, v of newFilters
        existingParams[k] = v

      newParams = {}

      _.each existingParams, (val, key) ->
        newParams[key] = val if val

      newParams["page"] ||= 1

      "/vendors#{if format? then '.'+format else ''}?#{$.param(newParams)}"

    ProcureIo.Backbone.router = new ProcureIo.Backbone.VendorRouter()

    @render()

    @sortView = new ProcureIo.Backbone.VendorSortView({filteredHref: @filteredHref})

    Backbone.history.start
      pushState: true

  reset: ->
    $("#vendors-admin-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['vendors_admin/page']()
    # rivets.bind(@$el, {filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderPagination: ->
    @paginationView ||= new ProcureIo.Backbone.PaginationView({filteredHref: @filteredHref, collection: ProcureIo.Backbone.Vendors})
    @paginationView.render()

  addOne: (vendor) ->
    view = new ProcureIo.Backbone.VendorView({model: vendor, parentView: @})
    $("#vendors-admin-tbody").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Vendors.each @addOne, @

  updateFilterFromForm: (e) ->
    ProcureIo.Backbone.router.navigate @filteredHref({page: 1}), {trigger: true}
    e.preventDefault()

  updateFilter: (e) ->
    return if e.metaKey
    ProcureIo.Backbone.router.navigate $(e.target).attr('href'), {trigger: true}
    e.preventDefault()

  removeLoadingSpinner: ->
    $("#vendors-admin-page").removeClass 'loading'

