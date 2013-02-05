$(document).on "focus", "[data-behavior=datepicker]", ->
  $(@).datepicker
    format: "yyyy-mm-dd"
    weekStart: 1
    autoclose: true
