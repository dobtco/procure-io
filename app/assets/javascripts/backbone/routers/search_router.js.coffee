ProcureIo.Backbone.SearchRouter = Backbone.Router.extend
  routes:
    '*params': 'main'

  initialize: (collection, defaults) ->
    @collection = collection
    @filterOptions = new Backbone.Model(_.extend(defaults, {page: 1}))

  filteredHref: (newFilters, format) ->
    existingParams = @filterOptions.toJSON()

    for k, v of newFilters
      existingParams[k] = v

    newParams = {}

    _.each existingParams, (val, key) ->
      newParams[key] = val if val

    currentUrl = (Backbone.history.fragment || document.URL).split('?')[0]

    "#{currentUrl}#{if format? then '.'+format else ''}?#{$.param(newParams)}"

  main: ->
    params = $.urlParams()

    if _.isEmpty(params)
      return @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}", {replace: true}

    @setParamsFromUrl(params)

    $(".search-page").addClass 'loading'

    @collection.fetch({data: _.extend(@filterOptions.toJSON(), {searcher: true})})

  setParamsFromUrl: (params) ->
    params ||= $.urlParams()
    return if _.isEmpty params

    for k, v of params
      @filterOptions.set k, v

    for k, v of @filterOptions.attributes
      @filterOptions.set k, undefined if !params[k] || params[k] == ""
