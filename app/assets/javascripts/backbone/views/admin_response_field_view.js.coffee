ProcureIo.Backbone.RESPONSE_FIELD_TYPES = [
  'checkboxes', 'radio', 'dropdown', 'text', 'paragraph', 'price', 'number', 'date', 'website', 'time', 'file'
]

ProcureIo.Backbone.AdminResponseFieldSubviews = {}

ProcureIo.Backbone.AdminResponseFieldSubviews['addField'] = Backbone.View.extend
  el: "#addField"

  render: ->
    @$el.html JST['admin_response_field/add_field']()

ProcureIo.Backbone.AdminResponseFieldView = Backbone.View.extend
  className: "response-field-wrapper"

  initialize: ->
    @parentView = @options.parentView
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove

  render: ->
    @$el.html JST['admin_response_field/view/base']
      response_field: @model

    @$el.find(".subtemplate-wrapper").html JST["admin_response_field/view/#{@model.get('field_type')}"]
      response_field: @model

    @$el.data('cid', @model.cid)

    return @

  focusEditView: ->
    @parentView.createAndShowEditView(@model)

  clear: ->
    @model.destroy()

ProcureIo.Backbone.AdminEditResponseFieldView = Backbone.View.extend
  className: "edit-response-field"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @parentView = @options.parentView

  render: ->
    @$el.html JST['admin_response_field/edit/base']
      response_field: @model
      parentView: @parentView

    @$el.find(".edit-subtemplate-wrapper").html JST["admin_response_field/edit/#{@model.get('field_type')}"]
      model: @model

    rivets.bind @$el,
      model: @model

    return @

  remove: ->
    @parentView.editView = undefined
    Backbone.View.prototype.remove.call(@)

  addOption: ->
    options = @model.get("field_options.options") || []
    options.push {label: "", checked: false}
    @model.set "field_options.options", options

  removeOption: (e, $el) ->
    index = @$el.find("[data-backbone-click=removeOption]").index($el)
    options = @model.get "field_options.options"
    options.splice index, 1
    @model.set "field_options.options", options

  defaultUpdated: (e, $el) ->
    @$el.find("[data-backbone-click=defaultUpdated]").not($el).attr('checked', false).trigger('change')
    @forceRender()

  forceRender: ->
    @model.trigger 'change'

ProcureIo.Backbone.AdminResponseFieldPage = Backbone.View.extend
  el: "#admin-response-field-page"

  initialize: ->
    @collection = new ProcureIo.Backbone.ResponseFieldList()
    @collection.urlParams = "response_fieldable_id=#{@options.response_fieldable_id}&response_fieldable_type=#{@options.response_fieldable_type}"
    @collection.baseUrl = "/response_fields?#{@collection.urlParams}"

    if @options.formOptions
      @response_fieldable = new Backbone.Model(@options.formOptions)
      @response_fieldable.bind 'change', @handleFormUpdate, @

    @collection.bind 'add', @addOne, @
    @collection.bind 'reset', @reset, @
    @collection.bind 'change', @handleFormUpdate, @
    @collection.bind 'destroy add reset', @toggleNoResponseFields, @
    @collection.bind 'destroy', @ensureEditViewScrolled, @

    @editView = undefined
    @addingAll = undefined

    @render()

    for key, subview of ProcureIo.Backbone.AdminResponseFieldSubviews
      new (@options.subviews?[key] || subview)({parentView: @}).render()

    @collection.reset(@options.bootstrapData)

    @formSaved = true
    @saveFormButton = @$el.find("[data-backbone-click=saveForm]")
    @saveFormButton.button 'loading'
    setInterval =>
      @saveForm.call(@)
    , 5000

    $(window).bind 'beforeunload', =>
      if @formSaved then undefined else 'You have unsaved changes. If you leave this page, you will lose those changes!'

  reset: ->
    $("#response-fields").html('')
    @addAll()

  render: ->
    @$el.html JST['admin_response_field/page']
      options: @options

    rivets.bind @$el,
      formOptions: @response_fieldable

    @$el.find("#response-fields").bind 'sortupdate', =>
      @updateSortOrder()
      @ensureEditViewScrolled()

    @toggleNoResponseFields()

    return @

  addOne: (responseField) ->
    $(".bid-form-span").removeClass 'loading'

    view = new ProcureIo.Backbone.AdminResponseFieldView
      model: responseField
      parentView: @

    $("#response-fields").append view.render().el
    @resetSortable() unless @addingAll

  resetSortable: ->
    @$el.find("#response-fields").sortable('destroy')
    @$el.find("#response-fields").sortable
      forcePlaceholderSize: true

  addAll: ->
    @addingAll = true
    @collection.each @addOne, @
    @addingAll = false
    @resetSortable()

  toggleNoResponseFields: ->
    @$el.find("#no-response-fields")[if @collection.length > 0 then 'hide' else 'show']()

  addField: (e, $el, field_type) ->
    attrs =
      label: "Untitled"
      field_type: field_type
      sort_order: @collection.nextSortOrder()
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

    @collection.create attrs,
      wait: true
      success: (rf) =>
        @createAndShowEditView(rf)

  createAndShowEditView: (model) ->
    $responseFieldEl = $(".response-field-wrapper").filter(-> $(@).data('cid') == model.cid)

    if @editView
      if @editView.model.cid is model.cid then return
      oldPadding = @editView.$el.css('padding-top')
      @editView.remove()

    @editView = new ProcureIo.Backbone.AdminEditResponseFieldView
      model: model
      parentView: @
      $responseFieldEl: $responseFieldEl

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


  ensureEditViewScrolled: ->
    return unless @editView

    @editView.$el.animate
      "padding-top": Math.max(0, @editView.options.$responseFieldEl.offset().top - $("#response-fields").offset().top - 25)
    , 'fast'

  updateSortOrder: ->
    i = 0
    self = @

    @$el.find(".response-field-wrapper").each ->
      model = self.collection.get $(@).data('cid')
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
      url: "/response_fields/batch?#{@collection.urlParams}"
      type: "PUT"
      contentType: "application/json"
      data: JSON.stringify({response_fields: @collection.toJSON(), form_options: @response_fieldable?.toJSON()})
