require 'spec_helper'

describe "Collaborator" do

  subject { page }

  describe "index", js: true do
    before do
      sign_in(officers(:adam).user)
      visit project_collaborators_path(projects(:one))
    end

    describe "basic rendering" do
      # @todo something about owner
      it { should have_selector('td', officers(:adam).user.email) }
      it { should have_selector('td', officers(:clay).user.email) }
    end

    describe "removing collaborator" do
      it "should remove collaborators from the list" do
        page.should have_selector('#collaborators-tbody tr', count: 2)
        find("#collaborators-tbody tr:eq(2) .btn").click
        page.should have_selector('#collaborators-tbody tr', count: 1)
        visit project_collaborators_path(projects(:one))
        page.should have_selector('#collaborators-tbody tr', count: 1)
      end
    end

    describe "adding duplicate collaborators" do
      it "should not allow duplicates" do
        page.should have_selector('#collaborators-tbody tr', count: 2)
        fill_in "email", with: officers(:adam).user.email
        click_button "Add Collaborator"
        expect(page).to have_selector("#new_collaborator .btn:not(.disabled)")
        page.should have_selector('#collaborators-tbody tr', count: 2)
        visit project_collaborators_path(projects(:one))
        page.should have_selector('#collaborators-tbody tr', count: 2)
      end
    end

    describe "adding collaborators" do
      before do
        collaborators(:clayone).destroy
        visit project_collaborators_path(projects(:one))
      end

      it "should allow you to add a new collaborator" do
        page.should have_selector('td', officers(:adam).user.email)
        page.should_not have_selector('td:contains("'+officers(:clay).user.email+'")')
        fill_in "email", with: officers(:clay).user.email
        click_button "Add Collaborator"
        expect(page).to have_selector("#new_collaborator .btn:not(.disabled)")
        page.should have_selector('#collaborators-tbody tr', count: 2)
        visit project_collaborators_path(projects(:one))
        page.should have_selector('td', text: officers(:adam).user.email)
        page.should have_selector('td', text: officers(:clay).user.email)
        page.should_not have_selector('tr[data-email="'+officers(:clay).user.email+'"] i.icon-envelope') # not an invited user
      end

      it "should allow you to add multiple collaborators at once" do
        page.should have_selector('#collaborators-tbody tr', count: 1)
        fill_in "email", with: "porkchop1@sandwich.es,porkchop2@sandwich.es"
        click_button "Add Collaborator"
        expect(page).to have_selector("#new_collaborator .btn:not(.disabled)")
        page.should have_selector('#collaborators-tbody tr', count: 3)
        visit project_collaborators_path(projects(:one))
        page.should have_selector('#collaborators-tbody tr', count: 3)
      end

      it "should allow you to invite unregistered users" do
        page.should have_selector('#collaborators-tbody tr', count: 1)
        fill_in "email", with: "porkchop3@sandwich.es"
        click_button "Add Collaborator"
        expect(page).to have_selector("#new_collaborator .btn:not(.disabled)")
        page.should have_selector('#collaborators-tbody tr', count: 2)
        visit project_collaborators_path(projects(:one))
        page.should have_selector('tr[data-email="porkchop3@sandwich.es"] i.icon-envelope')
      end
    end
  end

end
