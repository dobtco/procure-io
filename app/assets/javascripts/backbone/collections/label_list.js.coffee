ProcureIo.Backbone.LabelList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Label
  existingNames: ->
    @.reject((l) -> !l.get('id')).map (l) ->
      return l.attributes.name.toLowerCase()
