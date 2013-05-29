$ ->
  $("[data-toggle=radio-buttons]").each ->
    val = $(@).siblings("input[type=hidden]").val()
    $(@).find("[data-value=#{val}]").trigger('click')

$(document).on "click", "[data-toggle=radio-buttons]", (e) ->
  $(e.target).addClass('active').siblings().removeClass('active')
  $(@).siblings("input[type=hidden]").val $(e.target).data('value')
