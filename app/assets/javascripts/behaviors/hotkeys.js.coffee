# $ ->
#   Temporarily disabled: hotkeys

#   if ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]?
#     setTimeout ( -> $("#hotkeys-indicator").fadeIn(200) ), 300

#     for hotkey in ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]
#       $(document).bind "keydown", hotkey.key, hotkey.run

#     $(document).bind "keydown", "shift+/", toggleHotkeyModal

# toggleHotkeyModal = ->
#   if $("#hotkey-modal").length == 0
#     $("body").append JST['shared/hotkey_modal']
#       hotkeys: ProcureIo.Hotkeys["#{$('body').data('controller')}##{$('body').data('action')}"]

#   $("#hotkey-modal").modal('toggle')

# $(document).on "click", "#hotkeys-indicator", toggleHotkeyModal
