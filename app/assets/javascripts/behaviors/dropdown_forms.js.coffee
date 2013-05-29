$(document).on "click", ".js-dropdown-form-toggle", (e) ->
  $(@).parent().find("input[type=text], textarea").first().focus()
  $(document).bind "keydown.closedropdownform", (e) =>
    if (/(38|40|27)/.test(e.keyCode))
      $(document).off ".closedropdownform"
      $(@).closest(".dropdown.open").removeClass('open')

$(document).on "submit", ".dropdown-form", (e) ->
  $(@).closest(".dropdown.open").removeClass 'open'
