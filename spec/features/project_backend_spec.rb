require 'spec_helper'
include ProjectBackendSpecHelper

describe "Project Backend" do

  pending " :) "

  # before do
  #   sign_in(officers(:adam).user)
  # end

  # describe 'watching project' do
  #   it 'should let the user watch the project' do
  #     pending 'Going to change this UI soon'
  #   end
  # end

  # describe 'projects/:num/review_mode' do
  #   it 'should change the review mode' do
  #     pending 'Will probably update this feature soon'
  #   end
  # end

  # describe 'projects/:num/import_bids' do
  #   it 'should import bids from a csv file'
  # end

  # describe 'projects/:num/export_bids' do
  #   it 'should export bids to a csv file'
  # end

  # describe "projects/:num/collaborators", js: true do
  #   before do
  #     visit project_collaborators_path(projects(:one))
  #   end

  #   it "should render the list of collaborators" do
  #     page.should have_collaborator(officers(:adam))
  #     page.should have_collaborator(officers(:clay))
  #     collaborator(officers(:adam)).should be_owner
  #     collaborator(officers(:clay)).should_not be_owner
  #   end

  #   it "should remove collaborators" do
  #     page.should have_collaborators_count(2)
  #     last_collaborator.find("a", text: 'Remove').click
  #     before_and_after_refresh do
  #       page.should have_collaborators_count(1)
  #     end
  #   end

  #   it "should add collaborators" do
  #     # no duplicates
  #     page.should have_collaborators_count(2)
  #     fill_in "email", with: officers(:adam).user.email
  #     click_button "Add Collaborator"
  #     before_and_after_refresh do
  #       page.should have_collaborators_count(2)
  #     end

  #     # add
  #     collaborators(:clayone).destroy
  #     refresh
  #     page.should have_collaborators_count(1)
  #     fill_in "email", with: officers(:clay).user.email
  #     click_button "Add Collaborator"
  #     before_and_after_refresh do
  #       page.should have_collaborators_count(2)
  #     end

  #     # add multiple
  #     fill_in "email", with: "porkchop1@sandwich.es,porkchop2@sandwich.es"
  #     click_button "Add Collaborator"
  #     before_and_after_refresh do
  #       page.should have_selector('#collaborators-tbody tr', count: 4)
  #     end

  #     # unregistered collaborators should have been invited
  #     collaborator("porkchop1@sandwich.es").should be_invited
  #     collaborator("porkchop2@sandwich.es").should be_invited
  #     collaborator(officers(:adam)).should_not be_invited
  #     collaborator(officers(:clay)).should_not be_invited
  #   end

  #   it 'should change owner status when user is an owner' do
  #     # set owner
  #     collaborator(officers(:clay)).should_not be_owner
  #     collaborator(officers(:clay)).find('a', text: I18n.t('g.set_owner')).click
  #     collaborator(officers(:clay)).should be_owner

  #     # remove owner (even if it's you)
  #     collaborator(officers(:adam)).should be_owner
  #     collaborator(officers(:adam)).find('a', text: I18n.t('g.remove_owner')).click
  #     collaborator(officers(:adam)).should_not be_owner

  #     # cant remove last owner
  #     collaborators(:adamone).update_attributes(owner: true)
  #     collaborators(:clayone).update_attributes(owner: false)
  #     refresh
  #     collaborator(officers(:adam)).should be_owner
  #     collaborator(officers(:adam)).find('a', text: I18n.t('g.remove_owner')).click
  #     collaborator(officers(:adam)).should be_owner
  #     page.should have_text(I18n.t('flashes.cant_remove_last_owner'))
  #   end
  # end

  # describe "projects/mine", js: true do
  #   before do
  #     visit mine_projects_path
  #   end

  #   it 'should render only the projects where the user is a collaborator' do
  #     page.should have_text(projects(:one).title)
  #     collaborators(:adamone).destroy
  #     refresh
  #     page.should_not have_text(projects(:one).title)
  #   end
  # end

  # describe "projects/new" do
  #   before do
  #     visit new_project_path
  #   end

  #   it 'should create new projects' do
  #     fill_in "project[title]", with: "Ze Title"
  #     click_button I18n.t('g.submit')
  #     page.should have_selector('h3', 'Ze Title')
  #   end
  # end

  # describe "projects/:num/edit" do
  #   before do
  #     visit edit_project_path(projects(:one))
  #   end

  #   it 'should update the project' do
  #     page.should have_selector('form.edit_project')
  #     fill_in "project[title]", with: "awesome!"
  #     click_button I18n.t('g.update_project')
  #     page.should have_selector('h3', 'awesome!')
  #   end
  # end

  # describe "projects/:num/questions" do
  #   before do
  #     visit project_questions_path(projects(:one))
  #   end

  #   it 'should let the user update the questions with answers'
  # end

  # describe 'projects/:num/comments' do
  #   it 'should render the comments page'
  # end

  # describe 'projects/:num/reports' do
  #   it 'should render the reports'
  # end

end
