ProcureIo.Backbone.ResponseFieldList = Backbone.Collection.extend
  model: Backbone.DeepModel

  nextSortOrder: ->
    biggest = @.max((r) -> r.attributes.sort_order)

    if biggest.attributes
      biggest.attributes.sort_order + 1
    else
      1

