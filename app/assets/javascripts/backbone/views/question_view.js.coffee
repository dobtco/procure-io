ProcureIo.Backbone.QuestionView = Backbone.View.extend
  tagName: "div"
  className: "question well"

  template: _.template """
    <div class="question-body"><%- body %></div>
    <% if (answer_body){ %>
      <div id="answer-body-<%= id %>" class="answer-body collapse">
        <p><%- answer_body %></p>
        <span class="answered-by">Answered by X on <%= updated_at %></span>
      </div>
      <a data-toggle="collapse" data-target="#answer-body-<%= id %>" data-toggle-text="hide answer">show answer</a>
    <% } else { %>
      <div class="no-answer-body">Not yet answered.</div>
    <% } %>
  """

  # events:
  #   "click [data-backbone-clear]": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->
    @$el.html @template(@model.toJSON())
    @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.QuestionPage = Backbone.View.extend

  initialize: ->
    ProcureIo.Backbone.Questions = new ProcureIo.Backbone.QuestionList()
    ProcureIo.Backbone.Questions.url = "/projects/#{@options.projectId}/questions"

    ProcureIo.Backbone.Questions.bind 'add', @addOne, @
    ProcureIo.Backbone.Questions.bind 'reset', @reset, @
    ProcureIo.Backbone.Questions.bind 'all', @render, @

    ProcureIo.Backbone.Questions.reset(@options.bootstrapData)

  reset: ->
    $("#questions-list").html('')
    @addAll()

  # render: ->
  #   #

  addOne: (question) ->
    view = new ProcureIo.Backbone.QuestionView({model: question})
    $("#questions-list").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Questions.each @addOne

$(document).on "submit", "form#new_question", (e) ->
  e.preventDefault()
  return if !$(@).find("textarea").val()

  ProcureIo.Backbone.Questions.create
    body: $(@).find("textarea").val()
  ,
    error: (obj, err) ->
      obj.destroy()

  $(@).resetForm()
  $("#ask-question-toggle").click()

# ProcureIo.PageSpecificScripts["collaborators#index"] = ->
#   typeaheadTimeout = undefined

#   $("form#new_collaborator input[type=text]").typeahead
#     source: (query, process) ->
#       typeaheadTimeout ||= setTimeout ->
#         $.ajax
#           url: "/officers/typeahead.json"
#           data:
#             query: query
#           success: (data) ->
#             typeaheadTimeout = null

#             data = $.grep data, (value) ->
#               return ProcureIo.Backbone.Collaborators.existing_emails().indexOf(value) is -1

#             return process(data)
#       , 200

#     minLength: 3
