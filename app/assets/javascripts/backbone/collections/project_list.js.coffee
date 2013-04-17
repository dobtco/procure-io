ProcureIo.Backbone.ProjectList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Project
  parse: (resp, xhr) ->
    @meta = resp.meta
    resp.results
