$(document).on "mouseenter", ".js-notification-dropdown-toggle", ->
  $(@).tooltip('show') unless $(@).parent().hasClass('open')

$(document).on "mouseleave", ".js-notification-dropdown-toggle", ->
  $(@).tooltip('hide')

$(document).on "click", ".js-notification-dropdown-toggle", (e) ->
  $(@).tooltip('hide')
  return if $(@).data('notifications-loaded')
  $(@).data 'notifications-loaded', true

  $.ajax
    type: "get"
    dataType: "json"
    url: $(@).attr('href')
    success: (data) ->
      $("#notifications-dropdown").html JST['notification/dropdown']
        notifications: data.results
        count: data.meta.count
    error: =>
      $(@).data 'notifications-loaded', false
