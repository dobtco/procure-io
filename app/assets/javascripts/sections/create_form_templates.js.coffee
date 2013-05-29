$(document).on "ajax:beforeSend", "#form-template-form", (e) ->
  return false if !$(@).find("input[type=text]").val()

  $(@).resetForm().hide()
  $("#form-template-created").show()
  setTimeout ->
    $("#form-template-created").hide()
  , 2000
