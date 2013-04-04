ProcureIo.Backbone.NotificationView = Backbone.View.extend
  className: "notification"
  events:
    "click [data-backbone-toggleread]": "toggleRead"

  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove

  render: ->
    @$el.html JST['notification/notification'](@model.toJSON())
    @

  clear: ->
    @model.destroy()

  toggleRead: ->
    @model.save
      read: if @model.get('read') then false else true

ProcureIo.Backbone.NotificationPage = Backbone.View.extend

  initialize: ->
    ProcureIo.Backbone.Notifications = new ProcureIo.Backbone.NotificationList()

    ProcureIo.Backbone.Notifications.bind 'reset', @reset, @
    ProcureIo.Backbone.Notifications.bind 'all', @render, @

    ProcureIo.Backbone.Notifications.reset(@options.bootstrapData)

  reset: ->
    $("#notifications-list").html('')
    $("#no-notifications")[if ProcureIo.Backbone.Notifications.length > 0 then "hide" else "show"]()
    @addAll()

  # render: ->
  #   #

  addOne: (notification) ->
    view = new ProcureIo.Backbone.NotificationView({model: notification})
    $("#notifications-list").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Notifications.each @addOne
