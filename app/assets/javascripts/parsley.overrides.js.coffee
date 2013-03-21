$.fn.parsley.defaults.errors.classHandler = $.fn.parsley.defaults.errors.container = (el, isRadioOrCheckbox) ->
  el.closest(".control-group")

$.fn.parsley.defaults.errors.errorsWrapper = '<ul class="help-block"></ul>'
$.fn.parsley.defaults.errors.errorElem = '<li></li>'
$.fn.parsley.defaults.errorClass = 'error'