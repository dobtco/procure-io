ProcureIo.Backbone.AdminQuestionView = Backbone.View.extend
  tagName: "tr"

  events:
    "click [data-backbone-save]": "save"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->
    @$el.html JST['admin_question/question'](@model.toJSON())
    @

  # @todo data binding using rivets?
  save: ->
    @$el.find("button").button 'loading'

    @model.save
      answer_body: @$el.find("textarea").val()
    ,
      success: =>
        @$el.find("button").button 'reset'
        @$el.find("button").flash_button false, "Saved!"

ProcureIo.Backbone.AdminQuestionPage = Backbone.View.extend

  initialize: ->
    ProcureIo.Backbone.Questions = new ProcureIo.Backbone.QuestionList()
    ProcureIo.Backbone.Questions.url = "/projects/#{@options.projectId}/questions"

    ProcureIo.Backbone.Questions.bind 'add', @addOne, @
    ProcureIo.Backbone.Questions.bind 'reset', @reset, @
    ProcureIo.Backbone.Questions.bind 'all', @render, @

    ProcureIo.Backbone.Questions.reset(@options.bootstrapData)

  reset: ->
    $("#questions-tbody").html('')
    @addAll()

  addOne: (question) ->
    view = new ProcureIo.Backbone.AdminQuestionView({model: question})
    $("#questions-tbody").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Questions.each @addOne
