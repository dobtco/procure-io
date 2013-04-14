ProcureIo.Backbone.VendorTableHeadView = Backbone.View.extend
  el: "#vendors-thead"

  render: ->
    @$el.html JST['vendors_admin/thead']
      keyFields: @options.parentView.keyFields


ProcureIo.Backbone.VendorSortView = Backbone.View.extend
  el: "#sort-wrapper"

  events:
    "change .js-sort-select": "updateSort"
    "click .js-direction-select": "changeSortDirection"

  initialize: ->
    @filteredHref = @options.filteredHref

    @sortOptions = [{key: "name", label: "Name"}, {key: "email", label: "Email"}]

    _.each @options.parentView.options.response_fields, (rf) =>
      @sortOptions.push {key: ""+rf.id, label: rf.label}

    @render()
    ProcureIo.Backbone.router.filterOptions.bind "change", @render, @

  render: ->
    @$el.html JST['shared/select_sorters']({sortOptions: @sortOptions, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @filteredHref})

  changeSortDirection: (e) ->
    $(e.target).closest(".js-direction-select").toggleClass('sort-asc')

    href = @options.filteredHref
      direction: if ProcureIo.Backbone.router.filterOptions.get('direction') != "asc" then "asc" else "desc"

    ProcureIo.Backbone.router.navigate href, {trigger: true}

  updateSort: (e) ->
    href = @options.filteredHref
      sort: $(e.target).val()

    ProcureIo.Backbone.router.navigate href, {trigger: true}

ProcureIo.Backbone.VendorView = Backbone.View.extend
  tagName: "tr"
  className: "vendor"

  render: ->
    getValue = (id) =>
      response = _.find @model.get('vendor_profile.responses'), (response) ->
        response.response_field_id is id

      if response then response.display_value else ""

    @$el.html JST['vendors_admin/vendor']
      vendor: @model.toJSON()
      filteredHref: @options.parentView.filteredHref
      keyFields: @options.parentView.keyFields
      getValue: getValue

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
    ProcureIo.Backbone.Vendors.bind 'reset', @renderTableHead, @

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
    ProcureIo.Backbone.router.filterOptions.bind "change", @setKeyFields, @

    @render()

    @sortView = new ProcureIo.Backbone.VendorSortView({filteredHref: @filteredHref, parentView: @})

    Backbone.history.start
      pushState: true

  reset: ->
    $("#vendors-admin-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['vendors_admin/page']
      keyFields: @options.key_fields
    rivets.bind(@$el, {filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderPagination: ->
    @paginationView ||= new ProcureIo.Backbone.PaginationView({filteredHref: @filteredHref, collection: ProcureIo.Backbone.Vendors})
    @paginationView.render()

  renderTableHead: ->
    @tableHeadView ||= new ProcureIo.Backbone.VendorTableHeadView({parentView: @})
    @tableHeadView.render()

  addOne: (vendor) ->
    console.log @keyFields
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

  setKeyFields: ->
    keyFields = @options.key_fields.slice(0)

    if (responseFieldId = parseInt(ProcureIo.Backbone.router.filterOptions.get('sort'), 10)) > 0
      responseField = _.find @options.response_fields, ( (rf) -> rf.id == responseFieldId )
      keyFields.push(responseField) if responseField && !(_.find keyFields, ( (kf) -> kf.id == responseField.id ))

    @keyFields = keyFields

  removeLoadingSpinner: ->
    $("#vendors-admin-page").removeClass 'loading'

