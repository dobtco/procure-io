ProcureIo.PageSpecificScripts["form_templates#edit"] = ->
  $(".edit_form_template").on "ajax:beforeSend", ->
    $(@).find(".btn").button 'loading'

  $(".edit_form_template").on "ajax:success", ->
    $(@).find(".btn").button 'reset'