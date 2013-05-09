ProcureIo.PageSpecificScripts["projects#show"] = ->

  $(document).on "ajax:beforeSend", "form#new_question", ->
    return false unless $(@).find("textarea").val()
    $(@).find('.btn').button 'loading'
    $(@).resetForm()
