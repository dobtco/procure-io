$ ->
  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

  if ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"]?
    setTimeout ( -> $(".show-tour-link").fadeIn(200) ), 300

$(document).on "click", "[data-toggle-text]", ->
  newText = $(@).data('toggle-text')
  $(@).data "toggle-text", $(@).text()
  $(@).text newText

$(document).on "click", '[data-toggle=showhide]', ->
  $($(@).data('target')).toggleClass 'hide'

$(document).on "click", ".show-tour-link", (e) ->
  if (steps = ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"])?
    $.intro(steps)

$(document).on "ajax:complete", ".js-remove-bid-response-upload", (e) ->
  $(@).closest(".current-upload").remove()
