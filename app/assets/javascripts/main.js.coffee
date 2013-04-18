$ ->
  $("[data-toggle=tooltip], .js-notification-dropdown-toggle").tooltip()

  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

  if ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"]?
    setTimeout ( -> $(".show-tour-link").fadeIn(200) ), 300

  if ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]?
    setTimeout ( -> $("#hotkeys-indicator").fadeIn(200) ), 300

    for hotkey in ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]
      $(document).bind "keydown", hotkey.key, hotkey.run

    $(document).bind "keydown", "shift+/", toggleHotkeyModal

  $("[data-max-chars]").trigger('input')

$(document).on "click", "[data-toggle-text]", ->
  newText = $(@).data('toggle-text')
  $(@).data "toggle-text", $(@).text()
  $(@).text newText

$(document).on "click", '[data-toggle=showhide]', ->
  $($(@).data('target')).toggleClass 'hide'

$(document).on "click", "[data-toggle-class]", ->
  $($(@).data('target')).toggleClass($(@).data('toggle-class'))

$(document).on "click", ".show-tour-link", (e) ->
  if (steps = ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"])?
    $.intro(steps)

$(document).on "ajax:beforeSend", ".js-remove-bid-response-upload", (e) ->
  $fileInput = $(@).closest('.control-group').find('input[type=file]')
  $fileInput.data('value', false).trigger('change')
  $fileInput.closest('.fileupload').fileupload('clear')

$(document).on "input", "[data-max-chars]", ->
  value = $(@).val()
  count = value.length
  max = $(@).data('max-chars')
  remaining = if !value then max else max - count
  $($(@).data('max-chars-display')).text(remaining)

$(document).on "click", ".js-dropdown-login-toggle", (e) ->
  $(".dropdown-login-form input[type=text]:eq(0)").focus()
  $(document).bind "keydown.closeloginmodal", (e) ->
    if e.keyCode is 27
      $(document).off ".closeloginmodal"
      $(".dropdown.open").removeClass('open')

$(document).on "mouseenter", ".js-notification-dropdown-toggle", ->
  $(@).tooltip('show') unless $(@).parent().hasClass('open')

$(document).on "mouseleave", ".js-notification-dropdown-toggle", ->
  $(@).tooltip('hide')

$(document).on "click", ".js-notification-dropdown-toggle", (e) ->
  $(@).tooltip('hide')
  return if $(@).data('notifications-loaded')
  $(@).data 'notifications-loaded', true

  $.getJSON $(@).attr('href'), (data) ->
    $("#notifications-dropdown").html JST['notification/dropdown']
      notifications: data.results
      count: data.meta.count

toggleHotkeyModal = ->
  if $("#hotkey-modal").length == 0
    $("body").append JST['shared/hotkey_modal']
      hotkeys: ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]

  $("#hotkey-modal").modal('toggle')

$(document).on "click", "#hotkeys-indicator", toggleHotkeyModal

$(document).on "ajax:beforeSend", ".js-toggle-watch", (e) ->
  $(e.target).toggleClass('btn-inverse')
  $(e.target).closest(".watch-button-wrapper").toggleClass('watching')
