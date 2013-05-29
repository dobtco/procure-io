$(document).on "ajax:before", "form#new_question", ->
  return false unless $(@).find("textarea").val()
