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

    date: (val) ->
      return true if !val

      pieces = val.split(',')
      month = parseInt(pieces[0], 10)
      day = parseInt(pieces[1], 10)
      year = parseInt(pieces[2], 10)
      if pieces[2].length == 2 then year += 2000

      return (1 <= month <= 12) && (1 <= day <= 31) && (1900 <= year <= 2100)

  messages:
    minwords: "This value should have %s words at least."
    maxwords: "This value should have %s words maximum."
    date: "This value should be a valid date."