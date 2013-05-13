ProcureIo.Backbone.Bid = Backbone.DeepModel.extend
  getValue: (response_field_id) ->
    response = _.find @get('responses'), (response) ->
      response.response_field_id is response_field_id

    if response then response.display_value else ""

  badgedTextStatus: ->
    if @get('dismissed_at')
      """<span class="badge badge-important">#{I18n.t('g.dismissed')}</span>"""
    else if @get('awarded_at')
      """<span class="badge badge-success">#{I18n.t('g.awarded')}</span>"""
    else
      """<span class="badge badge-info">#{I18n.t('g.open')}</span>"""

