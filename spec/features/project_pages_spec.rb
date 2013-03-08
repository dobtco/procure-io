require 'spec_helper'

describe "Project" do

  subject { page }

  describe "logged out" do
    describe "index", js: true do
      before { visit projects_path }
      it { should have_text(projects(:one).title) }
    end
  end

  describe "logged in as vendor" do
    before do
      login_as(vendors(:one), scope: :vendor)
    end

    describe "show", js: true do
      before { visit project_path(projects(:one)) }
      it { should have_text(projects(:one).title) }

      it "should let vendors ask questions" do
        page.should have_selector("textarea#question_body", visible: false)
        find("#ask-question-toggle").click
        page.should have_selector("textarea#question_body", visible: true)
        find("#question_body").set("Shoop?")
        click_button "Submit Question"
        page.should have_selector('.question:contains("Shoop?")')
        visit project_path(projects(:one))
        page.should have_selector('.question:contains("Shoop?")')
      end

      it "should not let vendors submit blank questions" do
        count = all("#questions-list .question").length
        find("#question_body").set("")
        click_button "Submit Question"
        page.should have_selector("#questions-list .question", count: count)
        visit project_path(projects(:one))
        page.should have_selector("#questions-list .question", count: count)
      end
    end

  end

  describe "logged in as officer" do
    before do
      login_as(officers(:adam), scope: :officer)
    end

    describe "index", js: true do
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