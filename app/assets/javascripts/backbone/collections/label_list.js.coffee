ProcureIo.Backbone.LabelList = Backbone.Collection.extend
  model: Backbone.Model
  existingNames: ->
    @.reject((l) -> !l.get('id')).map (l) ->
      return l.attributes.name.toLowerCase()
