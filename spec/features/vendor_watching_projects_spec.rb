require 'spec_helper'

include VendorWatchingProjectsSpecHelper

describe 'Vendor Watching Projects' do

  before do
    sign_in(vendors(:one).user)
  end

  it 'should let vendors watch and unwatch projects', js: true do
    visit project_path(projects(:one))

    # Watch
    page.should_not be_watching
    click_watch_button
    before_and_after_refresh do
      page.should be_watching
    end

    # Unwatch
    page.should be_watching
    click_unwatch_button
    before_and_after_refresh do
      page.should_not be_watching
    end
  end

  it 'should alert vendors to amendments for projects that they are watching', js: true do
    vendors(:one).user.watch!(projects(:one))

    visit notifications_path
    page.should_not have_text(I18n.t('events.text.project_amended', project_title: projects(:one).title))

    amendment = projects(:one).amendments.create(title: "Foo", body: "Bar")
    amendment.post_by_officer(officers(:adam))

    refresh
    page.should have_text(I18n.t('events.text.project_amended', project_title: projects(:one).title))
  end

  describe 'the /watched_projects page' do
    before do
      vendors(:one).user.watch!(projects(:one))
      visit vendor_projects_watches_path
    end

    it 'should display watched projects' do
      page.should have_text(projects(:one).title)
      page.should_not have_text(projects(:two).title)
    end
  end

end