ProcureIo.Backbone.ProjectRouter = Backbone.Router.extend
  routes:
    'projects': 'projects'
    'projects?*params': 'projects'

  initialize: ->
    @filterOptions = new Backbone.Model
      "sort": "postedAt"
      "page": 1

  projects: (id, params) ->
    params = $.urlParams()
    if _.isEmpty(params) then @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}", {replace: true}
    @filterOptions.set "q", params?.q
    @filterOptions.set "category", params?.category
    @filterOptions.set "page", params?.page
    @filterOptions.set "sort", params?.sort
    @filterOptions.set "direction", params?.direction
    $("#project-page").addClass 'loading'
    ProcureIo.Backbone.Projects.fetch({data: @filterOptions.toJSON()})
