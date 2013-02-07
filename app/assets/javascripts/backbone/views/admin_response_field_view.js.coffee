ProcureIo.Backbone.AdminResponseFieldView = Backbone.View.extend
  tagName: "div"
  className: "response-field well"

  template: _.template """
    <div class="subtemplate-wrapper" data-backbone-cid="<%= cid %>"></div>
  """

  events:
    "click": "focusEditView"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @
    @parentView = @options.parentView

  render: ->
    @$el.html @template(_.extend(@model.toJSON(), {cid: @model.cid}))
    @$el.find(".subtemplate-wrapper").html @subTemplate(@model.toJSON())
    rivets.bind(@$el, {model: @model})

    return @

  focusEditView: ->
    @parentView.createAndShowEditView(@model)

  # @todo data binding using rivets?
  # save: ->

ProcureIo.Backbone.TextResponseFieldView = ProcureIo.Backbone.AdminResponseFieldView.extend
  subTemplate: _.template """
    <label data-text="model.label"></label>
    <input type="text" />
    <span class="help-block" data-text="model.options.description"></span>
  """

ProcureIo.Backbone.EditTextResponseFieldView = Backbone.View.extend
  template: _.template """
    <label>label</label>
    <input type="text" data-value="model.label" />

    <label>description</label>
    <textarea data-value="model.options.description"></textarea>
  """

  initialize: ->

  render: ->
    @$el.html @template()
    rivets.bind(@$el, {model: @model})
    return @

ProcureIo.Backbone.AdminResponseFieldPage = Backbone.View.extend

  el: "#admin-response-field-page"

  template: _.template """
    <div class="row-fluid">
      <div class="span5">
        <ul class="nav nav-tabs" id="response-field-tabs">
          <li class="active"><a href="#addNewField" data-toggle="tab">Add New Field</a></li>
          <li><a href="#editField" data-toggle="tab">Edit Field</a></li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active" id="addNewField">
            <a data-backbone-add-field="text">text</a>
            <a data-backbone-add-field="paragraph">paragraph</a>
          </div>
          <div class="tab-pane" id="editField">
            <div id="edit-response-field-wrapper"></div>
          </div>
        </div>
      </div>
      <div class="span7">
        <h4>Bid Form</h4>
        <div id="response-fields"></div>
      </div>
    </div>
  """

  events:
    "click [data-backbone-add-field]": "addNewField"

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
    @$el.html @template()

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

  createAndShowEditView: (model) ->
    if @editView && @editView.model != model
      @editView.remove()

    @editView = new ProcureIo.Backbone["Edit#{model.attributes.field_type.capitalize()}ResponseFieldView"]({model: model})
    @$el.find("#edit-response-field-wrapper").html @editView.render().el
    @$el.find("#response-field-tabs a[href=\"#editField\"]").click()

  updateSortOrder: ->
    i = 0

    @$el.find(".subtemplate-wrapper").each ->
      model = ProcureIo.Backbone.ResponseFields.getByCid $(@).data('backbone-cid')
      model.save
        sort_order: i

      i++