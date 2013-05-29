$ ->
  return unless $("#save-draft-button").length > 0

  draft_saved = true
  save_draft_button = $("#save-draft-button")
  save_draft_button.button('loading')

  handleFormUpdate = ->
    draft_saved = false
    save_draft_button.button('reset')

  saveBidDraft = ->
    return if draft_saved is true
    form = $("#responsable-form")
    form.find("input[name=draft_only]").val('true')
    form.ajaxSubmit()
    form.find("input[name=draft_only]").val('')
    draft_saved = true
    save_draft_button.button('loading')

  $("#responsable-form :input").on "input change", handleFormUpdate
  $("#save-draft-button").on "click", saveBidDraft

  window.setInterval (-> saveBidDraft()), 5000

  $("#responsable-form").on 'submit', ->
    draft_saved = true

  $(window).bind 'beforeunload', ->
    if draft_saved then undefined else 'You have unsaved changes. If you leave this page, you will lose those changes!'
