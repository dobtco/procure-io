ProcureIo.PageSpecificScripts["organizations"] = ->
  $("#organization_username").on "input", ->
    $(".js-username").text $(@).val() || 'username'

  $("#organization_username").trigger 'input'
