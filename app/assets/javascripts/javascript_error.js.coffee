# Display an error overlay when:
#   - we get an 'error' response to an AJAX request
#   - a request takes > 10 seconds

ProcureIo.JavascriptError = (message) ->
  $(".btn").button 'reset' # reset all 'loading' buttons

  timeoutError = !message

  message ||= I18n.t('g.javascript_error')
  $alert = $("""
    <div class="alert alert-error" id="javascript-error" style="display:none;">#{message}</div>
  """)

  $alert.appendTo("body")

  $alert.fadeIn(200)

  if !timeoutError
    setTimeout ->
      $alert.fadeOut 200, (-> $alert.remove())
    , 2500

ProcureIo.ClearJavascriptError = ->
  $("#javascript-error").remove()

$(document).on "ajaxSend", (_, xhr) ->
  xhr.timeoutId = setTimeout ->
    ProcureIo.JavascriptError()
  , 10000

$(document).on "ajaxSuccess", (_, xhr) ->
  ProcureIo.ClearJavascriptError()
  clearTimeout(xhr.timeoutId)

$(document).on "ajaxError", (_, xhr) ->
  # dont show error when request has been aborted
  clearTimeout(xhr.timeoutId)
  if xhr.getAllResponseHeaders()
    ProcureIo.JavascriptError($.parseJSON(xhr.responseText)['message'])
