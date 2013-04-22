ProcureIo.Backbone.ProjectList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Project
  parse: ProcureIo.Backbone.Overrides.parse
