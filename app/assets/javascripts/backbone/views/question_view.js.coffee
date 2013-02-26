ProcureIo.Backbone.QuestionView = Backbone.View.extend
  tagName: "div"
  className: "question well"

  # events:
  #   "click [data-backbone-clear]": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->
    @$el.html JST['question/question'](@model.toJSON())
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
