require 'spec_helper'

describe "Home" do

  describe 'the root page' do
    before do
      @projects = []
      3.times { @projects.push Project.create(posted_at: Time.now, title: 'Foo', abstract: 'Bar', featured: true) }
      visit root_path
    end

    it 'should show featured projects first' do
      3.times do # to account for random selection of featured projects
        visit root_path
        @projects.each do |project|
          page.should have_selector("a[href=\"#{project_path(project)}\"]")
        end
      end
    end

    it 'should show non-featured projects if there are not enough featured projects' do
      @projects.each { |p| p.update_attributes(featured: false) }
      refresh
      page.should have_selector(".featured-projects .project", count: 3)
    end

  end

  describe 'the navbar' do
    before do
      visit root_path
    end

    context 'when logged out' do
      it 'should have a signin link' do
        page.should have_selector("a", text: I18n.t('g.sign_in'))
      end
    end

    context 'when logged in' do
      it 'should show the users display_name' do
        sign_in(officers(:adam).user)
        refresh
        page.should have_text(officers(:adam).display_name)
      end
    end
  end

end
