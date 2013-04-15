$ ->
  $("[data-toggle=tooltip], .js-notification-dropdown-toggle").tooltip()

  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

  if ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"]?
    setTimeout ( -> $(".show-tour-link").fadeIn(200) ), 300

  $("[data-max-chars]").trigger('input')

$(document).on "click", "[data-toggle-text]", ->
  newText = $(@).data('toggle-text')
  $(@).data "toggle-text", $(@).text()
  $(@).text newText

$(document).on "click", '[data-toggle=showhide]', ->
  $($(@).data('target')).toggleClass 'hide'

$(document).on "click", "[data-toggle-class]", ->
  $($(@).data('target')).toggleClass($(@).data('toggle-class'))

$(document).on "click", ".show-tour-link", (e) ->
  if (steps = ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"])?
    $.intro(steps)

$(document).on "ajax:complete", ".js-remove-bid-response-upload", (e) ->
  $fileInput = $(@).closest('.control-group').find('input[type=file]')
  $(@).closest(".current-upload").remove()
  $fileInput.data('value', false).trigger('change')

$(document).on "input", "[data-max-chars]", ->
  value = $(@).val()
  count = value.length
  max = $(@).data('max-chars')
  remaining = if !value then max else max - count
  $($(@).data('max-chars-display')).text(remaining)

$(document).on "click", ".js-dropdown-login-toggle", (e) ->
  $(".dropdown-login-form input[type=text]:eq(0)").focus()
  $(document).bind "keydown.closeloginmodal", (e) ->
    if e.keyCode is 27
      $(document).off ".closeloginmodal"
      $(".dropdown.open").removeClass('open')

$(document).on "mouseenter", ".js-notification-dropdown-toggle", ->
  console.log 'l'
  $(@).tooltip('show') unless $(@).parent().hasClass('open')

$(document).on "mouseleave", ".js-notification-dropdown-toggle", ->
  $(@).tooltip('hide')

$(document).on "click", ".js-notification-dropdown-toggle", (e) ->
  $(@).tooltip('hide')
  return if $(@).data('notifications-loaded')
  $(@).data 'notifications-loaded', true

  $.getJSON $(@).attr('href'), (data) ->
    $("#notifications-dropdown").html JST['notification/dropdown']
      notifications: data.notifications
      count: data.meta.count

