include ApplicationHelper

def sign_in(user)
  visit root_path
  fill_in "user_session[email]", with: user.email
  fill_in "user_session[password]", with: "password"
  click_button "Sign in"
end

def sign_out
  visit root_path
  find("[href*=\"/sign_out\"]").click
end