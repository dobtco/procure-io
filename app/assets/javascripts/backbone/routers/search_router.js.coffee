ProcureIo.Backbone.SearchRouter = Backbone.Router.extend
  routes:
    '*params': 'main'

  initialize: (collection, defaults) ->
    @collection = collection
    @filterOptions = new Backbone.Model(_.extend(defaults, {page: 1}))
    window.f = @filterOptions

  main: (id, params) ->
    params = $.urlParams()

    if _.isEmpty(params)
      return @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}", {replace: true}

    for k, v of params
      @filterOptions.set k, v

    for k, v of @filterOptions.attributes
      @filterOptions.set k, undefined if !params[k] || params[k] == ""

    $(".search-page").addClass 'loading'

    @collection.fetch({data: @filterOptions.toJSON()})
