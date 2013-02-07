ProcureIo.Backbone.ResponseFieldList = Backbone.Collection.extend
  model: ProcureIo.Backbone.ResponseField

  nextSortOrder: ->
    biggest = @.max((r) -> r.attributes.sort_order)

    if biggest
      biggest.attributes.sort_order + 1
    else
      1

