$("form#new_collaborator .btn").button 'reset'
$("#collaborators-table").replaceWith("""<%= render "collaborators/table", collaborators: @collaborators %>""")