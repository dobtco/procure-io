ProcureIo.Backbone.AdminResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "response-field-wrapper"

  events:
    "click .subtemplate-wrapper": "focusEditView"
    "click .remove-field-button": "clear"

  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove
    @parentView = @options.parentView

  render: ->
    @$el.html JST['admin_response_field/view/base'](_.extend(@model.toJSON(), {cid: @model.cid}))
    @$el.find(".subtemplate-wrapper").html JST[@subTemplate](@model.toJSON())
    @$el.data('cid', @model.cid)
    return @

  focusEditView: (e) ->
    $target = if $(e.target).hasClass('response-field-wrapper') then $(e.target) else $(e.target).closest(".response-field-wrapper")
    @parentView.createAndShowEditView(@model)

  clear: ->
    @model.destroy()

for i in ['checkboxes', 'radio', 'dropdown', 'text', 'paragraph', 'price', 'number', 'date', 'website', 'time', 'file']
  ProcureIo.Backbone["#{i.capitalize()}ResponseFieldView"] = ProcureIo.Backbone.AdminResponseFieldView.extend
    subTemplate: "admin_response_field/view/#{i}"

ProcureIo.Backbone.AdminEditResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "edit-response-field"

  events:
    "click .backbone-add-option": "addOption"
    "click .backbone-remove-option": "removeOption"

  initialize: ->
    @listenTo @model, "destroy", @removeEditView
    @listenTo @model, "destroy", @remove
    @parentView = @options.parentView

  render: ->
    @$el.html JST['admin_response_field/edit/base'](@model.toJSON())
    @$el.find(".edit-subtemplate-wrapper").html JST[@subTemplate](_.extend(@model.toJSON(), {cid: @model.cid}))
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

  defaultUpdated: (e) ->
    @$el.find("[data-backbone-defaultoption]").not($(e.target)).attr('checked', false).trigger('change')
    @forceRender()

  forceRender: ->
    @model.trigger 'change'

ProcureIo.Backbone.EditFileResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/file'

ProcureIo.Backbone.EditWebsiteResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/website'

ProcureIo.Backbone.EditDateResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/date'

ProcureIo.Backbone.EditTimeResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/time'

ProcureIo.Backbone.EditPriceResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/price'

ProcureIo.Backbone.EditNumberResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/number'

ProcureIo.Backbone.EditTextResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/text'

ProcureIo.Backbone.EditParagraphResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/paragraph'

ProcureIo.Backbone.EditCheckboxesResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/checkboxes'

  initialize: ->
    ProcureIo.Backbone.AdminEditResponseFieldView.prototype.initialize.apply(@)
    @extendEvents
      "input input[type=text]": "forceRender"
      "click input[type=checkbox]": "forceRender"

ProcureIo.Backbone.EditDropdownResponseFieldView = ProcureIo.Backbone.EditCheckboxesResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/dropdown'

  initialize: ->
    ProcureIo.Backbone.AdminEditResponseFieldView.prototype.initialize.apply(@)
    @extendEvents
      "input input[type=text]": "forceRender"
      "click [data-backbone-defaultoption]": "defaultUpdated"

ProcureIo.Backbone.EditRadioResponseFieldView = ProcureIo.Backbone.EditCheckboxesResponseFieldView.extend
  subTemplate: 'admin_response_field/edit/radio'

  initialize: ->
    ProcureIo.Backbone.AdminEditResponseFieldView.prototype.initialize.apply(@)
    @extendEvents
      "input input[type=text]": "forceRender"
      "click [data-backbone-defaultoption]": "defaultUpdated"

ProcureIo.Backbone.AdminResponseFieldFormOptionsView = Backbone.View.extend
  el: "#form-options-wrapper"

  initialize: ->
    @render()

  render: ->
    @$el.html JST['admin_response_field/form_options']()
    rivets.bind(@$el, {project: ProcureIo.Backbone.CurrentProject})
    return @

ProcureIo.Backbone.AdminResponseFieldPage = Backbone.View.extend
  el: "#admin-response-field-page"

  events:
    "click [data-backbone-add-field]": "addNewField"
    "click [data-backbone-save-form]": "saveForm"

  initialize: ->
    ProcureIo.Backbone.ResponseFields = new ProcureIo.Backbone.ResponseFieldList()
    ProcureIo.Backbone.ResponseFields.url = "/projects/#{@options.project.id}/response_fields"
    ProcureIo.Backbone.CurrentProject = new ProcureIo.Backbone.Project(@options.project)
    ProcureIo.Backbone.CurrentProject.url = "/projects/#{@options.project.id}"

    ProcureIo.Backbone.ResponseFields.bind 'add', @addOne, @
    ProcureIo.Backbone.ResponseFields.bind 'reset', @reset, @
    ProcureIo.Backbone.ResponseFields.bind 'change', @handleFormUpdate, @
    ProcureIo.Backbone.CurrentProject.bind 'change', @handleFormUpdate, @
    ProcureIo.Backbone.ResponseFields.bind 'destroy add reset', @toggleNoResponseFields, @

    @editView = undefined

    @render()
    @formOptionsView = new ProcureIo.Backbone.AdminResponseFieldFormOptionsView()
    ProcureIo.Backbone.ResponseFields.reset(@options.bootstrapData)

    @formSaved = true
    @saveFormButton = @$el.find("[data-backbone-save-form]")
    @saveFormButton.button 'loading'
    setInterval =>
      @saveForm.call(@)
    , 5000

    $(window).bind 'beforeunload', =>
      if @formSaved then undefined else 'You have unsaved changes. If you leave this page, you will lose those changes!'

    $("#form-template-form").on "submit", (e) ->
      $(e.target).ajaxSubmit
        success: ->
          $(e.target).find("button").flash_button("success", "Saved!")
          $(e.target).resetForm()

          setTimeout ->
            $(e.target).addClass('hide')
          , 990

      e.preventDefault()

  reset: ->
    $("#response-fields").html('')
    @addAll()

  render: ->
    @$el.html JST['admin_response_field/page'](ProcureIo.Backbone.CurrentProject.toJSON())
    rivets.bind(@$el, {project: ProcureIo.Backbone.CurrentProject})

    @$el.find("#response-fields").bind 'sortupdate', =>
      @updateSortOrder()

    @toggleNoResponseFields()

    return @

  addOne: (responseField) ->
    $(".bid-form-span").removeClass 'loading'

    view = new ProcureIo.Backbone["#{responseField.attributes.field_type.capitalize()}ResponseFieldView"]({model: responseField, parentView: @})

    el = view.render().el
    $("#response-fields").append(el)
    $("#response-fields").sortable('destroy')
    $("#response-fields").sortable
      forcePlaceholderSize: true

  addAll: ->
    ProcureIo.Backbone.ResponseFields.each @addOne, @

  toggleNoResponseFields: ->
    @$el.find("#no-response-fields")[if ProcureIo.Backbone.ResponseFields.length > 0 then 'hide' else 'show']()

  addNewField: (e) ->
    attrs =
      label: "Untitled"
      key_field: false
      field_type: $(e.target).data("backbone-add-field")
      sort_order: ProcureIo.Backbone.ResponseFields.nextSortOrder()
      field_options:
        required: true

    switch attrs.field_type
      when "checkboxes", "dropdown", "radio"
        attrs.field_options.options = [
          label: "",
          checked: false
        ,
          label: "",
          checked: false
        ]

      when "dropdown"
        attrs.field_options.include_blank_option = false

      when "text", "paragraph"
        attrs.field_options.size = "small"

    $(".bid-form-span").addClass 'loading'

    ProcureIo.Backbone.ResponseFields.create attrs,
      wait: true
      success: (rf) =>
        @createAndShowEditView(rf)

  # @todo scroll edit view when removing fields above it
  createAndShowEditView: (model) ->
    $responseFieldEl = $(".response-field-wrapper").filter(-> $(@).data('cid') == model.cid)

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

    if ($(window).height() - $responseFieldEl.offset().top) < 200
      $(window).scrollTo($responseFieldEl, 200)

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
      data: JSON.stringify({response_fields: ProcureIo.Backbone.ResponseFields.toJSON(), project: ProcureIo.Backbone.CurrentProject.toJSON()})
      # success: (data) =>
      # @todo implement error callback