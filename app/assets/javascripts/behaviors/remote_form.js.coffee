$(document).on "ajax:beforeSend", "form[data-remote]", ->
  $(@).resetForm() unless $(@).hasClass 'js-no-reset'
  $(@).find('[data-loading-text]').button('loading')
