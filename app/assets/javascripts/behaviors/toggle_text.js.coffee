$.fn.extend
  toggleText: ->
    @each ->
      newText = $(@).data('toggle-text')
      $(@).data "toggle-text", $(@).text()
      $(@).text newText

$(document).on "click", "[data-toggle-text]", ->
  $(@).toggleText()
