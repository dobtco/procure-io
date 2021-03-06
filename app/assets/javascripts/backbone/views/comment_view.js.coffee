ProcureIo.Backbone.CommentView = Backbone.View.extend
  tagName: "div"
  className: "comment comment-normal well"

  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove

  render: ->
    @$el.html JST['comment/comment']
      comment: @model

    @

  deleteComment: ->
    @$el.fadeOut 300, =>
      @model.destroy()

ProcureIo.Backbone.CommentBidDismissedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-bid-dismissed"
  render: ->
    @$el.html JST['comment/comment_bid_dismissed'](@model.toJSON())
    @

ProcureIo.Backbone.CommentBidUndismissedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-bid-undismissed"
  render: ->
    @$el.html JST['comment/comment_bid_undismissed'](@model.toJSON())
    @

ProcureIo.Backbone.CommentProjectPostedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-project-posted"
  render: ->
    @$el.html JST['comment/comment_project_posted'](@model.toJSON())
    @

ProcureIo.Backbone.CommentProjectUnpostedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-project-unposted"
  render: ->
    @$el.html JST['comment/comment_project_unposted'](@model.toJSON())
    @

ProcureIo.Backbone.CommentBidAwardedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-bid-awarded"
  render: ->
    @$el.html JST['comment/comment_bid_awarded'](@model.toJSON())
    @

ProcureIo.Backbone.CommentProjectBidAwardedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-project-bid-awarded"
  render: ->
    @$el.html JST['comment/comment_project_bid_awarded'](@model.toJSON())
    @

ProcureIo.Backbone.CommentBidUnawardedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-bid-unawarded"
  render: ->
    @$el.html JST['comment/comment_bid_unawarded'](@model.toJSON())
    @

ProcureIo.Backbone.CommentProjectBidUnawardedView = ProcureIo.Backbone.CommentView.extend
  className: "comment comment-project-bid-unawarded"
  render: ->
    @$el.html JST['comment/comment_project_bid_unawarded'](@model.toJSON())
    @

ProcureIo.Backbone.CommentPageView = Backbone.View.extend
  el: "#comment-page"

  initialize: ->
    @$el = @options.el if @options.el?

    @comments = new ProcureIo.Backbone.CommentList()
    @comments.urlParams = "commentable_type=#{@options.commentableType}&commentable_id=#{@options.commentableId}"
    @comments.baseUrl = "/comments?#{@comments.urlParams}"
    @comments.url = @comments.baseUrl

    @comments.bind 'add', @addOne, @
    @comments.bind 'reset', @reset, @

    @render()

    ProcureIo.Backbone.Comment.prototype.defaults = =>
      commentable_type: @options.commentableType
      commentable_id: @options.commentableId

    if @options.bootstrapData
      @comments.reset(@options.bootstrapData)
    else
      @comments.fetch()

  reset: ->
    @$el.find(".loading-comments").hide()
    $("#comments-wrapper").html('')
    @addAll()

  render: ->
    @$el.html JST['comment/page']()
    @$el.find("form").parsley()
    @

  addOne: (comment) ->
    if comment.get("comment_type")
      view = new ProcureIo.Backbone["Comment#{comment.get('comment_type')}View"]({model: comment})
    else
      view = new ProcureIo.Backbone.CommentView({model: comment})
    $("#comments-wrapper").append(view.render().el)

  addAll: ->
    @comments.each @addOne

  createComment: (e, $el) ->
    @comments.create
      body: $el.find("textarea").val()
      user: ProcureIo.CurrentUser

    $el.resetForm()

