$(".no-preview").hide()
$(".preview-column-wrapper").removeClass('loading')
$(".preview-wrapper").html("""<%= render "form_templates/preview" %>""")