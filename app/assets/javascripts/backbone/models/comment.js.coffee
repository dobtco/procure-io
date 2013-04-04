ProcureIo.Backbone.Comment = Backbone.Model.extend
  url: ProcureIo.Backbone.Overrides.modelUrl
  initialize: ->
    @attributes.data = JSON.parse(@attributes.data) if @attributes.data?
  validate: ->
