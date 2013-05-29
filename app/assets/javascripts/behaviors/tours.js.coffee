$ ->
  if ProcureIo.CurrentTour
    setTimeout ->
      $(".show-tour-link").fadeIn(200)
      $(".show-tour-link").click() if !ProcureIo.ViewedTour
    , 300

$(document).on "click", ".show-tour-link", (e) ->
  $.intro(ProcureIo.CurrentTour) if ProcureIo.CurrentTour?
