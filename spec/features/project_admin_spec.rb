require 'spec_helper'
include ProjectAdminSpecHelper

describe "Project Admin" do

  describe "collaborators#index", js: true do
    before do
      sign_in(officers(:adam).user)
      visit project_collaborators_path(projects(:one))
    end

    it "should render the list of collaborators" do
      page.should have_collaborator(officers(:adam))
      page.should have_collaborator(officers(:clay))
      collaborator(officers(:adam)).should be_owner
      collaborator(officers(:clay)).should_not be_owner
    end

    it "should remove collaborators" do
      page.should have_collaborators_count(2)
      last_collaborator.find("a", text: 'Remove').click
      before_and_after_refresh do
        page.should have_collaborators_count(1)
      end
    end

    it "should add collaborators" do
      # no duplicates
      page.should have_collaborators_count(2)
      fill_in "email", with: officers(:adam).user.email
      click_button "Add Collaborator"
      before_and_after_refresh do
        page.should have_collaborators_count(2)
      end

      # add
      collaborators(:clayone).destroy
      refresh
      page.should have_collaborators_count(1)
      fill_in "email", with: officers(:clay).user.email
      click_button "Add Collaborator"
      before_and_after_refresh do
        page.should have_collaborators_count(2)
      end

      # add multiple
      fill_in "email", with: "porkchop1@sandwich.es,porkchop2@sandwich.es"
      click_button "Add Collaborator"
      before_and_after_refresh do
        page.should have_selector('#collaborators-tbody tr', count: 4)
      end

      # unregistered collaborators should have been invited
      collaborator("porkchop1@sandwich.es").should be_invited
      collaborator("porkchop2@sandwich.es").should be_invited
      collaborator(officers(:adam)).should_not be_invited
      collaborator(officers(:clay)).should_not be_invited
    end

    it 'should change owner status when user is an owner' do
      # set owner
      collaborator(officers(:clay)).should_not be_owner
      collaborator(officers(:clay)).find('a', text: I18n.t('g.set_owner')).click
      collaborator(officers(:clay)).should be_owner

      # remove owner (even if it's you)
      collaborator(officers(:adam)).should be_owner
      collaborator(officers(:adam)).find('a', text: I18n.t('g.remove_owner')).click
      collaborator(officers(:adam)).should_not be_owner

      # cant remove last owner
      collaborators(:adamone).update_attributes(owner: true)
      collaborators(:clayone).update_attributes(owner: false)
      refresh
      collaborator(officers(:adam)).should be_owner
      collaborator(officers(:adam)).find('a', text: I18n.t('g.remove_owner')).click
      collaborator(officers(:adam)).should be_owner
      page.should have_text(I18n.t('flashes.cant_remove_last_owner'))
    end
  end

end
