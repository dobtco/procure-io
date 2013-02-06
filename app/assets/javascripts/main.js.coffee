$ ->
  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

$(document).on "click", "[data-toggle-text]", ->
  newText = $(@).data('toggle-text')
  $(@).data "toggle-text", $(@).text()
  $(@).text newText