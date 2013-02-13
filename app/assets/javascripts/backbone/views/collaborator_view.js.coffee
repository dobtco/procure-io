ProcureIo.Backbone.CollaboratorView = Backbone.View.extend
  tagName: "tr"

  events:
    "click [data-backbone-clear]": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @
    @isOwner = (ProcureIo.Backbone.Collaborators.ownerId == ProcureIo.CurrentOfficerId)

  render: ->
    @$el.html JST['collaborator/collaborator'](_.extend(@model.toJSON(), isOwner: @isOwner))
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

  $(@).find("button").button 'loading'

  ProcureIo.Backbone.Collaborators.create
    officer:
      email: $(@).find("input[type=text]").val()
  ,
    wait: true
    error: (obj, err) ->
      obj.destroy()
    complete: =>
      $(@).find("button").button 'reset'

  $(@).resetForm()

ProcureIo.PageSpecificScripts["collaborators#index"] = ->
  typeaheadTimeout = undefined

  $("form#new_collaborator input[type=text]").typeahead
    source: (query, process) ->
      typeaheadTimeout ||= setTimeout ->
        $.ajax
          url: "/officers/typeahead.json"
          data:
            query: query
          success: (data) ->
            typeaheadTimeout = null

            data = $.grep data, (value) ->
              return ProcureIo.Backbone.Collaborators.existingEmails().indexOf(value) is -1

            return process(data)
      , 200

    minLength: 3
