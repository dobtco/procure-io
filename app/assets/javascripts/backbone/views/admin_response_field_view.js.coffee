ProcureIo.Backbone.AdminResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "response-field"

  events:
    "click .subtemplate-wrapper": "focusEditView"
    "click .remove-field-button": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @
    @parentView = @options.parentView

  render: ->
    @$el.html JST['admin_response_field/view/base'](_.extend(@model.toJSON(), {cid: @model.cid}))
    @$el.find(".subtemplate-wrapper").html JST[@subTemplate](@model.toJSON())

    return @

  focusEditView: (e) ->
    $target = if $(e.target).hasClass('response-field') then $(e.target) else $(e.target).closest(".response-field")
    @parentView.createAndShowEditView(@model, $target)

  clear: ->
    @model.destroy()

for i in ['checkboxes', 'radio', 'dropdown', 'text', 'paragraph']
  ProcureIo.Backbone["#{i.capitalize()}ResponseFieldView"] = ProcureIo.Backbone.AdminResponseFieldView.extend
    subTemplate: "admin_response_field/view/#{i}"

ProcureIo.Backbone.AdminEditResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "edit-response-field"

  events:
    "click .backbone-add-option": "addOption"
    "click .backbone-remove-option": "removeOption"

  initialize: ->
    @model.bind "destroy", @removeEditView, @
    @model.bind "destroy", @remove, @
    @parentView = @options.parentView

  render: ->
    @$el.html JST['admin_response_field/edit/base'](@model.toJSON())
    @$el.find(".subtemplate-wrapper").html JST[@subTemplate](_.extend(@model.toJSON(), {cid: @model.cid}))
    rivets.bind(@$el, {model: @model})

    return @

  removeEditView: ->
    @parentView.editView = undefined

  addOption: ->
    options = @model.get("field_options.options") || []
    options.push {label: "", checked: false}
    @model.set "field_options.options", options

  removeOption: (e) ->
    index = $(".backbone-remove-option").index(e.target)
    options = @model.get "field_options.options"
    options.splice index, 1
    @model.set "field_options.options", options

ProcureIo.Backbone.EditTextResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/text'

ProcureIo.Backbone.EditParagraphResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/paragraph'

ProcureIo.Backbone.EditCheckboxesResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/checkboxes'

  initialize: ->
    ProcureIo.Backbone.AdminEditResponseFieldView.prototype.initialize.apply(@)
    @events = _.extend
      "input input[type=text]": "forceRender"
      "click input[type=checkbox]": "forceRender"
    ,
      ProcureIo.Backbone.AdminEditResponseFieldView.prototype.events

  forceRender: ->
    console.log 'forcerender'
    @model.trigger 'change'

ProcureIo.Backbone.EditDropdownResponseFieldView = ProcureIo.Backbone.EditCheckboxesResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/dropdown'

  initialize: ->
    ProcureIo.Backbone.EditCheckboxesResponseFieldView.prototype.initialize.apply(@)
    @events = _.extend
      "input input[type=text]": "forceRender"
      "click [data-backbone-defaultoption]": "defaultUpdated"
    ,
      ProcureIo.Backbone.AdminEditResponseFieldView.prototype.events

  defaultUpdated: (e) ->
    @$el.find("[data-backbone-defaultoption]").not($(e.target)).attr('checked', false).trigger('change')
    @forceRender()

ProcureIo.Backbone.EditRadioResponseFieldView = ProcureIo.Backbone.EditCheckboxesResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/radio'

  initialize: ->
    ProcureIo.Backbone.EditCheckboxesResponseFieldView.prototype.initialize.apply(@)
    @events = _.extend
      "input input[type=text]": "forceRender"
      "click [data-backbone-defaultoption]": "defaultUpdated"
    ,
      ProcureIo.Backbone.AdminEditResponseFieldView.prototype.events

    console.log @events

  defaultUpdated: (e) ->
    @$el.find("[data-backbone-defaultoption]").trigger('change')
    @forceRender()


ProcureIo.Backbone.AdminResponseFieldPage = Backbone.View.extend
  el: "#admin-response-field-page"

  events:
    "click [data-backbone-add-field]": "addNewField"
    "click [data-backbone-save-form]": "saveForm"

  initialize: ->
    ProcureIo.Backbone.ResponseFields = new ProcureIo.Backbone.ResponseFieldList()
    ProcureIo.Backbone.ResponseFields.url = "/projects/#{@options.projectId}/response_fields"

    ProcureIo.Backbone.ResponseFields.bind 'add', @addOne, @
    ProcureIo.Backbone.ResponseFields.bind 'reset', @reset, @
    ProcureIo.Backbone.ResponseFields.bind 'change add destroy', @handleFormUpdate, @

    @editView = undefined

    @render()
    ProcureIo.Backbone.ResponseFields.reset(@options.bootstrapData)

    @formSaved = true
    @saveFormButton = @$el.find("[data-backbone-save-form]")
    @saveFormButton.button 'loading'
    setInterval =>
      @saveForm.call(@)
    , 5000

  reset: ->
    $("#response-fields").html('')
    @addAll()

  render: ->
    @$el.html JST['admin_response_field/page']()

    @$el.find("#response-fields").bind 'sortupdate', =>
      @updateSortOrder()

    return @

  addOne: (responseField) ->
    view = new ProcureIo.Backbone["#{responseField.attributes.field_type.capitalize()}ResponseFieldView"]({model: responseField, parentView: @})

    $("#response-fields").append(view.render().el)
    $("#response-fields").sortable('destroy')
    $("#response-fields").sortable
      forcePlaceholderSize: true

  addAll: ->
    ProcureIo.Backbone.ResponseFields.each @addOne, @

  addNewField: (e) ->
    attrs =
      field_type: $(e.target).data("backbone-add-field")
      sort_order: ProcureIo.Backbone.ResponseFields.nextSortOrder()
      field_options: {}

    if attrs.field_type is "checkboxes" or attrs.field_type is "dropdown" or attrs.field_type is "radio"
      attrs.field_options.options = [
        label: "",
        checked: false
      ,
        label: "",
        checked: false
      ]

    if attrs.field_type is "dropdown"
      attrs.field_options.include_blank_option = false

    ProcureIo.Backbone.ResponseFields.create attrs

  # @todo scroll edit view when removing fields above it
  createAndShowEditView: (model, $responseFieldEl) ->
    if @editView
      if @editView.model.cid is model.cid then return
      oldPadding = @editView.$el.css('padding-top')
      @editView.remove()

    @editView = new ProcureIo.Backbone["Edit#{model.attributes.field_type.capitalize()}ResponseFieldView"]({model: model, parentView: @})
    $newEditEl = @editView.render().$el
    @$el.find("#edit-response-field-wrapper").html $newEditEl
    @$el.find("#response-field-tabs a[href=\"#editField\"]").click()


    if oldPadding
      $newEditEl.css {"padding-top": oldPadding}

    $newEditEl.animate
      "padding-top": Math.max(0, $responseFieldEl.offset().top - $("#response-fields").offset().top - 25)
    , 'fast'

  updateSortOrder: ->
    i = 0

    @$el.find(".subtemplate-wrapper").each ->
      model = ProcureIo.Backbone.ResponseFields.get $(@).data('backbone-cid')
      model.set('sort_order', i)
      i++

    @saveForm()

  handleFormUpdate: ->
    @formSaved = false
    @saveFormButton.button('reset')

  saveForm: (e) ->
    return if @formSaved is true
    @formSaved = true
    @saveFormButton.button 'loading'

    $.ajax
      url: ProcureIo.Backbone.ResponseFields.url + "/batch"
      type: "PUT"
      contentType: "application/json"
      data: JSON.stringify({response_fields: ProcureIo.Backbone.ResponseFields.toJSON()})
      # success: (data) =>
      # @todo implement error callback