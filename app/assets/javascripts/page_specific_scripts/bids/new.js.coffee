ProcureIo.PageSpecificScripts["bids#new"] = ->

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

  setInterval saveBidDraft, 5000
