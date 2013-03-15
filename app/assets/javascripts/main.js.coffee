$ ->
  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

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
    el: ->
      $(".container > .btn-inverse")
    text: "This ."
  ,
    el: "a.vendor-name"
    text: "This is the bid review page."
]


$(document).on "ajax:complete", ".js-remove-bid-response-upload", (e) ->
  $(@).closest(".current-upload").remove()

$(document).on "click", ".js-show-tour", (e) ->
  return unless (tour = ProcureIo.Tours["#{$('body').data('controller')}##{$('body').data('action')}"])?
  new DobtTour(tour)
