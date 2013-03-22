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

  calculateHiddenDate = ($el, validate = true) ->
    month = $el.find("input:eq(0)").val()
    day = $el.find("input:eq(1)").val()
    year = $el.find("input:eq(2)").val()

    $el.find("input:eq(3)").val(if year or month or day then "#{month},#{day},#{year}" else "")
    $el.find("input:eq(3)").parsley('validate') if validate

  $(".input-group-date input[type=text]").on "input change", (e) ->
    calculateHiddenDate($(@).closest(".input-group-date"))

  $(".input-group-date").each ->
    calculateHiddenDate($(@), false)

  calculateHiddenTime = ($el, validate = true) ->
    hours = $el.find("input:eq(0)").val()
    minutes = $el.find("input:eq(1)").val()
    seconds = $el.find("input:eq(2)").val()

    $el.find("input:eq(3)").val(if hours or minutes or seconds then "#{hours},#{minutes},#{seconds}" else "")
    $el.find("input:eq(3)").parsley('validate') if validate

  $(".input-group-time").find("input[type=text], select").on "input change", (e) ->
    calculateHiddenTime($(@).closest(".input-group-time"))

  $(".input-group-time").each ->
    calculateHiddenTime($(@), false)

