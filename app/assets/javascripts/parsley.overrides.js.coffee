$.fn.parsley.defaults.errors.classHandler = $.fn.parsley.defaults.errors.container = (el, isRadioOrCheckbox) ->
  el.closest(".control-group")

$.fn.parsley.defaults.errors.errorsWrapper = '<ul class="help-block"></ul>'
$.fn.parsley.defaults.errors.errorElem = '<li></li>'
$.fn.parsley.defaults.errorClass = 'error'

window.ParsleyConfig ||= {}

window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig,
  validators:
    minwords: (val, nbWords) ->
      val = val.replace( /(^\s*)|(\s*$)/gi, "" );
      val = val.replace( /[ ]{2,}/gi, " " );
      val = val.replace( /\n /, "\n" );
      val = val.split(' ').length;

      return val >= nbWords;

    maxwords: (val, nbWords) ->
      val = val.replace( /(^\s*)|(\s*$)/gi, "" );
      val = val.replace( /[ ]{2,}/gi, " " );
      val = val.replace( /\n /, "\n" );
      val = val.split(' ').length;

      return val <= nbWords;

  messages:
    minwords: "This value should have %s words at least."
    maxwords: "This value should have %s words maximum."
