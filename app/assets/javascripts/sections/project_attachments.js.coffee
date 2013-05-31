$(document).on "click", "form.edit_project .js-add-another", ->
  $newField = $(".new-attachment-fields .fileupload").eq(0).clone()
  $newField.fileupload 'clear'
  $(".new-attachment-fields").append $newField

$(document).on "ajax:success", "form.edit_project .js-remove-attachment", ->
  $(@).closest('li').remove()
