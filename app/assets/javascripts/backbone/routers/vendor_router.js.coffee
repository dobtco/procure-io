ProcureIo.Backbone.VendorRouter = Backbone.Router.extend
  routes:
    'vendors': 'vendors'
    'vendors?*params': 'vendors'

  initialize: ->
    @filterOptions = new Backbone.Model
      "sort": "name"
      "direction": "asc"
      "page": 1

  vendors: (id, params) ->
    params = $.urlParams()
    if _.isEmpty(params) then return @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}", {replace: true}
    @filterOptions.set "q", params?.q
    @filterOptions.set "page", params?.page
    @filterOptions.set "sort", params?.sort
    @filterOptions.set "direction", params?.direction
    $("#vendors-admin-page").addClass 'loading'
    ProcureIo.Backbone.Vendors.fetch({data: @filterOptions.toJSON()})
