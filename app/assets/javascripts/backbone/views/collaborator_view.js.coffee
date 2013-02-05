ProcureIo.Backbone.CollaboratorView = Backbone.View.extend
  tagName: "tr"

  template: _.template """
    <td class="email">
      <%- email %>
      <% if (owner) { %><i class="icon-star"></i><% } %>
    </td>
    <td>
      <% if (isOwner){ %>
        <button class="btn btn-danger" data-backbone-clear>Remove</button>
      <% } %>
    </td>
  """

  events:
    "click [data-backbone-clear]": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @
    @isOwner = (ProcureIo.Backbone.Collaborators.ownerId == ProcureIo.CurrentOfficerId)

  render: ->
    @$el.html @template(_.extend(@model.toJSON(), isOwner: @isOwner))
    @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.CollaboratorPage = Backbone.View.extend

  initialize: ->
    ProcureIo.Backbone.Collaborators = new ProcureIo.Backbone.CollaboratorList()
    ProcureIo.Backbone.Collaborators.url = "/projects/#{@options.projectId}/collaborators"
    ProcureIo.Backbone.Collaborators.ownerId = @options.ownerId

    ProcureIo.Backbone.Collaborators.bind 'add', @addOne, @
    ProcureIo.Backbone.Collaborators.bind 'reset', @reset, @
    ProcureIo.Backbone.Collaborators.bind 'all', @render, @

    ProcureIo.Backbone.Collaborators.reset(@options.bootstrapData)

  reset: ->
    $("#collaborators-tbody").html('')
    @addAll()

  # render: ->
  #   #

  addOne: (collaborator) ->
    view = new ProcureIo.Backbone.CollaboratorView({model: collaborator})
    $("#collaborators-tbody").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Collaborators.each @addOne

$(document).on "submit", "form#new_collaborator", (e) ->
  e.preventDefault()

  ProcureIo.Backbone.Collaborators.create
    email: $(@).find("input[type=text]").val()
  ,
    error: (obj, err) ->
      obj.destroy()

  $(@).resetForm()