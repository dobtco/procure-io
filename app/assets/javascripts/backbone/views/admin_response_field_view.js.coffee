ProcureIo.Backbone.AdminResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "response-field"

  template: _.template """
    <div class="subtemplate-wrapper well" data-backbone-cid="<%= cid %>"></div>
    <div class="actions-wrapper">
      <button class="btn btn-mini remove-field-button">Remove Field</button>
    </div>
  """

  events:
    "click .subtemplate-wrapper": "focusEditView"
    "click .remove-field-button": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @
    @parentView = @options.parentView

  render: ->
    @$el.html @template(_.extend(@model.toJSON(), {cid: @model.cid}))
    @$el.find(".subtemplate-wrapper").html @subTemplate(@model.toJSON())
    rivets.bind(@$el, {model: @model})

    return @

  focusEditView: (e) ->
    $target = if $(e.target).hasClass('response-field') then $(e.target) else $(e.target).closest(".response-field")
    @parentView.createAndShowEditView(@model, $target)

  # @todo data binding using rivets?
  # save: ->

  clear: ->
    @model.destroy()


ProcureIo.Backbone.TextResponseFieldView = ProcureIo.Backbone.AdminResponseFieldView.extend
  subTemplate: _.template """
    <label>
      <span data-text="model.label"></span>
      <span data-show="model.field_options.required" class="required-asterisk">*</span>
    </label>
    <input type="text" />
    <span class="help-block" data-text="model.field_options.description"></span>
  """

ProcureIo.Backbone.ParagraphResponseFieldView = ProcureIo.Backbone.AdminResponseFieldView.extend
  subTemplate: _.template """
    <label>
      <span data-text="model.label"></span>
      <span data-show="model.field_options.required" class="required-asterisk">*</span>
    </label>
    <textarea />
    <span class="help-block" data-text="model.field_options.description"></span>
  """

ProcureIo.Backbone.AdminEditResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "edit-response-field"

  initialize: ->
    @model.bind "destroy", @removeEditView, @
    @parentView = @options.parentView

  template: _.template """
    <h5>
      Editing "<span data-text="model.label"></span>"
      <i class="icon-arrow-right pull-right"></i>
    </h5>
    <div class="subtemplate-wrapper"></div>
  """

  render: ->
    @$el.html @template(@model.toJSON())
    @$el.find(".subtemplate-wrapper").html @subTemplate(@model.toJSON())
    rivets.bind(@$el, {model: @model})

    return @

  removeEditView: ->
    @parentView.editView = undefined
    @remove()

  # @todo data binding using rivets?
  # save: ->


ProcureIo.Backbone.EditTextResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: _.template """
    <label>label</label>
    <input type="text" data-value="model.label" />

    <label class="checkbox">
      required?
      <input type="checkbox" data-checked="model.field_options.required" />
    </label>

    <label class="checkbox">
      key field?
      <input type="checkbox" data-checked="model.key_field" />
    </label>

    <label>description</label>
    <textarea data-value="model.field_options.description"></textarea>
  """

ProcureIo.Backbone.EditParagraphResponseFieldView = ProcureIo.Backbone.AdminEditResponseFieldView.extend
  subTemplate: _.template """
    <label>label</label>
    <input type="text" data-value="model.label" />

    <label class="checkbox">
      required?
      <input type="checkbox" data-checked="model.field_options.required" />
    </label>

    <label class="checkbox">
      key field?
      <input type="checkbox" data-checked="model.key_field" />
    </label>

    <label>description</label>
    <textarea data-value="model.field_options.description"></textarea>
  """

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

    @editView = undefined

    @render()
    ProcureIo.Backbone.ResponseFields.reset(@options.bootstrapData)

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
    ProcureIo.Backbone.ResponseFields.create
      field_type: $(e.target).data("backbone-add-field")
      sort_order: ProcureIo.Backbone.ResponseFields.nextSortOrder()

  createAndShowEditView: (model, $responseFieldEl) ->
    if @editView && @editView.model != model
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

  saveForm: ->
    $.ajax
      url: ProcureIo.Backbone.ResponseFields.url + "/batch"
      type: "PUT"
      data:
        response_fields: ProcureIo.Backbone.ResponseFields.toJSON()
      success: (data) =>
        @$el.find("[data-backbone-save-form]").flash_button false, "Saved!"