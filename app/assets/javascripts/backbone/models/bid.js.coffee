ProcureIo.Backbone.Bid = Backbone.DeepModel.extend
  getValue: (response_field_id) ->
    response = _.find @get('responses'), (response) ->
      response.response_field_id is response_field_id

    if response then response.display_value else ""
