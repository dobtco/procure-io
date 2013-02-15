ProcureIo.Backbone.ProjectRouter = Backbone.Router.extend
  routes:
    'projects': 'projects'
    'projects*params': 'projects'

  initialize: ->
    @filterOptions = new Backbone.Model
      # "f1": "all"
      # "f2": "open"
      # "sort": "createdAt"

  projects: (id, params) ->
    # params = $.urlParams()
    # if _.isEmpty(params) then @navigate "#{Backbone.history.fragment}?#{$.param(@filterOptions.toJSON())}", {replace: true}
    # @filterOptions.set "f1", params?.f1
    # @filterOptions.set "f2", params?.f2
    # @filterOptions.set "page", params?.page
    # @filterOptions.set "sort", params?.sort
    # @filterOptions.set "direction", params?.direction
    # $("#project-page").addClass 'loading'
    ProcureIo.Backbone.Projects.fetch({data: @filterOptions.toJSON()})
