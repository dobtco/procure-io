require 'spec_helper'

describe 'Vendor Watching Projects' do

  before do
    sign_in(vendors(:one).user)
  end

  it 'should let vendors watch and unwatch projects', js: true do
    watches(:three).destroy
    visit project_path(projects(:one))

    # Watch
    page.should have_text "Watch Project"
    find('.btn', text: "Watch Project").click
    before_and_after_refresh do
      page.should_not have_text "Watch Project"
      page.should have_text "Watching Project"
    end

    # Unwatch
    page.should have_text "Watching Project"
    find('.btn', text: "Watching Project").click
    before_and_after_refresh do
      page.should_not have_text "Watching Project"
      page.should have_text "Watch Project"
    end
  end

  it 'should alert vendors to amendments for projects that they are watching', js: true do
    visit notifications_path
    page.should_not have_text(I18n.t('events.text.project_amended', project_title: projects(:one).title))

    amendment = projects(:one).amendments.create(title: "Foo", body: "Bar")
    amendment.post_by_officer(officers(:adam))

    refresh
    page.should have_text(I18n.t('events.text.project_amended', project_title: projects(:one).title))
  end

  describe 'the /watched_projects page' do
    before do
      visit vendor_projects_watches_path
    end

    it 'should display watched projects' do
      page.should have_text(projects(:one).title)
      page.should_not have_text(projects(:two).title)
    end
  end

end