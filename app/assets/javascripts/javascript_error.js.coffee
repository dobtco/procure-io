ProcureIo.JavascriptError = ->
  $alert = $("""
    <div class="alert alert-error" id="javascript-error" style="display:none;">#{I18n.js('javascript_error')}</div>
  """)

  $alert.appendTo("body")

  $alert.fadeIn(200)

ProcureIo.ClearJavascriptError = ->
  $("#javascript-error").remove()

$(document).ajaxError (e, xhr, options) ->
  # dont show error when request has been aborted
  if xhr.getAllResponseHeaders()
    ProcureIo.JavascriptError()

$(document).on "ajaxSend", (_, xhr) ->
  xhr.timeoutId = setTimeout ->
    ProcureIo.JavascriptError()
  , 10000

$(document).on "ajaxSuccess", (_, xhr) ->
  ProcureIo.ClearJavascriptError()
  clearTimeout(xhr.timeoutId)
