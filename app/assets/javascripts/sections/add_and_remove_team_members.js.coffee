$(document).on "ajax:before", "form#add_team_member", ->
  email = $(@).find("[name=email]").val()
  existingEmails = _.map $("#member-table td:nth-child(2)"), (td) -> $(td).text()
  if !email || existingEmails.indexOf(email) != -1
    $(@).resetForm()
    return false

$(document).on "ajax:success", ".js-remove-member", ->
  $(@).closest("tr").remove()
