$ ->
  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

  if ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"]?
    setTimeout ( -> $(".show-tour-link").fadeIn(200) ), 300


$(document).on "click", "[data-toggle-text]", ->
  newText = $(@).data('toggle-text')
  $(@).data "toggle-text", $(@).text()
  $(@).text newText

$(document).on "click", '[data-toggle=showhide]', ->
  $($(@).data('target')).toggleClass 'hide'

## save bid draft ##

ProcureIo.PageSpecificScripts["bids#new"] = ->

  draft_saved = true
  save_draft_button = $("#save-draft-button")
  save_draft_button.button('loading')

  handleFormUpdate = ->
    draft_saved = false
    save_draft_button.button('reset')

  saveBidDraft = ->
    return if draft_saved is true
    form = $("#new-bid-form")
    form.find("input[name=draft_only]").val('true')
    form.ajaxSubmit()
    form.find("input[name=draft_only]").val('')
    draft_saved = true
    save_draft_button.button('loading')

  $("#new-bid-form :input").on "input change", handleFormUpdate
  $("#save-draft-button").on "click", saveBidDraft

  setInterval saveBidDraft, 5000

ProcureIo.Tours["bids#index"] = [
    el: "#bids-table"
    text: "These are the bids that you've received to date."
    placement: "top"
  ,
    el: "#actions-wrapper"
    text: "You can execute batch actions by checking multiple bids and then clicking one of these actions."
    placement: 'right'
  ,
    el: ".search-query"
    text: "You can also search the full text of your bids. Go nuts!"
  ,
    el: "a.vendor-name:eq(0)"
    text: "To view a bid, just click the vendor's name. Have fun!"
]

$(document).on "ajax:complete", ".js-remove-bid-response-upload", (e) ->
  $(@).closest(".current-upload").remove()

$(document).on "click", ".show-tour-link", (e) ->
  if (steps = ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"])?
    $.intro(steps)
