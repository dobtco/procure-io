ProcureIo.Backbone.Comment = Backbone.Model.extend
  initialize: ->
    @attributes.data = JSON.parse(@attributes.data) if @attributes.data?
  validate: ->
