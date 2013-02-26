$ = jQuery

$.fn.extend
  flash_button: (button_class, message, timeout) ->
    timeout ||= 1000

    return @each ->
      button = $(this)
      original_text = button.text()
      original_classes = button.attr('class')

      if button_class
        button.removeClass('btn-primary btn-info btn-success btn-warning btn-danger btn-inverse btn-link')
        button.addClass("btn-#{button_class}")

      button.text(message)

      setTimeout ->
        if button_class
          button.attr('class', original_classes)
          button.removeClass('disabled')
        button.text(original_text)
      , timeout