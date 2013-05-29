ProcureIo.PageSpecificScripts["organizations"] = ->
  $("#organization_username").on "input", ->
    $(".js-username").text $(@).val()
    $(".js-username-wrapper")[if !$(@).val() then 'hide' else 'show']()

  $("#organization_username").trigger 'input'
