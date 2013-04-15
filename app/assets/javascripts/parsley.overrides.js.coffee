$.fn.parsley.defaults.errors.classHandler = $.fn.parsley.defaults.errors.container = (el, isRadioOrCheckbox) ->
  el.closest(".control-group")

$.fn.parsley.defaults.errors.errorsWrapper = '<div class="help-block"></div>'
$.fn.parsley.defaults.errors.errorElem = '<span></span>'
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
      val = $.extend {}, val

      return true if !val['month'] && !val['year'] && !val['day']

      for i of val
        val[i] = if isNaN(parseInt(val[i], 10)) then 0 else parseInt(val[i], 10)

      (1 <= val['month'] <= 12) && (1 <= val['day'] <= 31) && (1900 <= val['year'] <= 2100)

    time: (val) ->
      val = $.extend {}, val

      return true if !val['hours'] && !val['minutes'] && !val['seconds']

      for i of val
        val[i] = if isNaN(parseInt(val[i], 10)) then 0 else parseInt(val[i], 10)

      (1 <= val['hours'] <= 12) && (0 <= val['minutes'] <= 60) && (0 <= val['seconds'] <= 60)

  messages:
    minwords: "This value should have %s words at least."
    maxwords: "This value should have %s words maximum."
    date: "This value should be a valid date."
    time: "This value should be a valid time."
