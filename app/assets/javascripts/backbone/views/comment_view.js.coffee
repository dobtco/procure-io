ProcureIo.Backbone.CommentView = Backbone.View.extend
  tagName: "div"
  className: "comment well"

  events:
    "click [data-backbone-clear]": "clear"

  initialize: ->
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->
    @$el.html JST['comment/comment'](_.extend(@model.toJSON(), {currentOfficerId: $("body").data("officer-id")}))
    @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.CommentPageView = Backbone.View.extend
  el: "#comment-page"

  initialize: ->
    ProcureIo.Backbone.Comments = new ProcureIo.Backbone.CommentList()
    ProcureIo.Backbone.Comments.url = "/comments"

    ProcureIo.Backbone.Comments.bind 'add', @addOne, @
    ProcureIo.Backbone.Comments.bind 'reset', @reset, @

    @render()

    ProcureIo.Backbone.Comment.prototype.defaults = =>
      commentable_type: @options.commentableType
      commentable_id: @options.commentableId

    ProcureIo.Backbone.Comments.reset(@options.bootstrapData)

  reset: ->
    $("#comments-wrapper").html('')
    @addAll()

  render: ->
    @$el.html JST['comment/page']()
    @

  addOne: (comment) ->
    view = new ProcureIo.Backbone.CommentView({model: comment})
    $("#comments-wrapper").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Comments.each @addOne

$(document).on "submit", "form#new-comment-form", (e) ->
  e.preventDefault()

  $(@).find("button").button 'loading'

  ProcureIo.Backbone.Comments.create
    body: $(@).find("textarea").val()
  ,
    wait: true

    error: (obj, err) ->
      obj.destroy()

    complete: =>
      $(@).find("button").button 'reset'

  $(@).resetForm()

