require 'spec_helper'

include LoggingInSpecHelper

describe "Logging In" do

  pending " :) "

  # subject { page }

  # describe "Valid login from dropdown" do
  #   it "should log in and redirect you to your current path" do
  #     visit projects_path
  #     fill_in "Email", with: "adam@test.com"
  #     fill_in "Password", with: "password"
  #     click_button "Sign in"
  #     page.should be_logged_in
  #     page.should have_text I18n.t("flashes.valid_login")
  #     current_path.should == projects_path

  #     # and then log out
  #     click_link I18n.t('g.sign_out')
  #     current_path.should == root_path
  #     page.should_not be_logged_in
  #   end
  # end

  # describe "Valid login from login page" do
  #   it "should log in and redirect you to your previous path" do
  #     Capybara.current_session.driver.header 'Referer', projects_path
  #     visit sign_in_path
  #     Capybara.current_session.driver.header 'Referer', nil
  #     find(".signin-page-input-email").set "adam@test.com"
  #     find(".signin-page-input-password").set "password"
  #     find(".signin-page-submit-button").click
  #     page.should be_logged_in
  #     page.should have_text I18n.t("flashes.valid_login")
  #     current_path.should == projects_path
  #   end
  # end

  # describe "login from unauthorized page" do
  #   it "should log in and redirect you to the same page" do
  #     visit response_fields_project_path(projects(:one))
  #     page.should have_text(I18n.t('g.sign_in'))
  #     fill_in "Email", with: "adam@test.com"
  #     fill_in "Password", with: "password"
  #     click_button "Sign in"
  #     current_path.should == response_fields_project_path(projects(:one))
  #     page.should have_text I18n.t("flashes.valid_login")
  #   end
  # end

  # describe "Invalid login" do
  #   before do
  #     visit projects_path
  #     fill_in "Email", with: "adam@test.com"
  #     fill_in "Password", with: "asdf"
  #     click_button "Sign in"
  #   end

  #   it "should display the login page with an error and your email filled in" do
  #     find(".signin-page-input-email").value.should == "adam@test.com"
  #     page.should have_text I18n.t("flashes.invalid_login")
  #     current_path.should == sign_in_path
  #   end

  #   describe "and then valid login" do
  #     it "should redirect to proper path" do
  #       find(".signin-page-input-password").set "password"
  #       find(".signin-page-submit-button").click
  #       page.should be_logged_in
  #       page.should have_text I18n.t("flashes.valid_login")
  #       current_path.should == projects_path
  #     end
  #   end
  # end

end
