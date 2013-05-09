ProcureIo.PageSpecificScripts["projects#show"] = ->

  $(document).on "ajax:beforeSend", "form#new_question", ->
    $(@).find('.btn').button 'loading'
    $(@).resetForm()
