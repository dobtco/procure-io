$(document).on "ajax:before", "[data-loading-text]", ->
  $(@).button 'loading'

$(document).on "ajax:success", "[data-remote]", ->
  $(@).find("[data-loading-text]").button 'reset'
