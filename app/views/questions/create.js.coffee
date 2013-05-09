$("form#new_question .btn").button 'reset'
$("#questions-list").append("""<%= render "questions/question", question: @question %>""")
$("#ask-question-toggle").click()
$("#no-questions").hide()
