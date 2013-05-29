$(document).on "ajax:beforeSend", ".js-remove-bid-response-upload", (e) ->
  $fileInput = $(@).closest('.control-group').find('input[type=file]')
  $fileInput.data('value', false).trigger('change')
  $fileInput.closest('.fileupload').fileupload('clear')
