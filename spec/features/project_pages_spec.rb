require 'spec_helper'

describe "Project" do

  subject { page }

  describe "logged out" do
    describe "index" do
      before { visit projects_path }
      it { should have_text(projects(:one).title) }
    end
  end

  describe "logged in" do
    before do
      login_as(officers(:adam), scope: :officer)
    end

    describe "index" do
      before { visit projects_path }
      it { should have_text(projects(:one).title) }
      it { should have_text(officers(:adam).name) }
    end

    describe "mine" do
      before { visit mine_projects_path }
      it { should have_text("My Projects") }
      it { should have_text(projects(:one).title) }

      describe "project edit page" do
        before { click_link(projects(:one).title) }
        it { should have_selector('form.edit_project') }

        describe "project page" do
          before { click_link("View Project") }
          it { should have_text("You're a collaborator on this project") }
        end

        describe "editing project" do
          before do
            fill_in "Title", with: "awesome!"
            click_button "Update Project"
          end
          it { should have_selector('input[value="awesome!"]') }
        end
      end
    end

    describe "new project page" do
      before { visit new_project_path }
      it { should have_selector('form.new_project') }

      describe "creating project" do
        before do
          fill_in "Title", with: "Ze Title"
          click_button "Next"
        end
        it { should have_selector('h3', 'Ze Title') }
      end
    end

  end
end