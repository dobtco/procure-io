$ ->
  # Show tooltips
  $("[data-toggle=tooltip], .js-notification-dropdown-toggle").tooltip()

  # Fitvids
  $(".js-fitvid").fitVids()

  # Init controller & page specific javascripts
  ProcureIo.PageSpecificScripts[$('body').data('controller')]?()
  ProcureIo.PageSpecificScripts["#{$('body').data('controller')}##{$('body').data('action')}"]?()

  $(".js-wysihtml5").wysihtml5
    "font-styles": false
    size: 'small'
