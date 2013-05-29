ProcureIo.Backbone.Collection = Backbone.Collection.extend
  initialize: (options = {}) ->
    @model = if options.deepModel? then Backbone.DeepModel else Backbone.Model
    @url = options.url
