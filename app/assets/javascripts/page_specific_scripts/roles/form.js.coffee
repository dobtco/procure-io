showHideQuickPermissions = ->
  if !$("input[name=quick_permissions]:checked").val()
    $(".quick-permissions").show()
  else
    $(".quick-permissions").hide()

ProcureIo.PageSpecificScripts["roles#new"] = ProcureIo.PageSpecificScripts["roles#edit"] = ->
  showHideQuickPermissions()

  $("input[name=quick_permissions]").change showHideQuickPermissions