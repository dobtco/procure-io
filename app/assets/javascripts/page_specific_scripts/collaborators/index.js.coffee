ProcureIo.PageSpecificScripts["collaborators#index"] = ->
  typeaheadTimeout = undefined

  $("form#new_collaborator input[type=text]").typeahead
    source: (query, process) ->
      existingEmails = $("#collaborators-tbody tr").map(-> $(@).data('email')).get()

      typeaheadTimeout ||= setTimeout ->
        $.ajax
          url: "/officers/typeahead.json"
          data:
            query: query
          success: (data) ->
            typeaheadTimeout = null

            data = $.grep data, (value) ->
              return existingEmails.indexOf(value) is -1

            return process(data)
      , 200

    minLength: 3

$(document).on "ajax:beforeSend", "form#new_collaborator", ->
  $(@).find("input[type=text]").blur()
  $(@).find('.btn').button 'loading'
  $(@).resetForm()

$(document).on "click", ".js-remove-collaborator-btn", ->
  $(@).closest('tr').remove()

$(document).on "click", ".js-toggle-single-bulk", ->
  $(".email-inputs").toggleClass('using-bulk')
  $(".email-inputs :input:visible").attr('disabled', false)
  $(".email-inputs :input:not(:visible)").attr('disabled', true)