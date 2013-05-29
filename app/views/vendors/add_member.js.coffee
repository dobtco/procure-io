$("form#add_team_member .btn").button 'reset'

<% if @user %>
$("#member-table").append("""<%= render "vendors/member", user: @user %>""")
<% end %>