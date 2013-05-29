$("form#add_team_member .btn").button 'reset'

<% if @user %>
$("#member-table").append("""<%= render "teams/member", user: @user %>""")
<% end %>