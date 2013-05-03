require 'spec_helper'

describe 'Making a Bid' do

  before { sign_in(vendors(:one).user) }

  describe 'bids#new' do
    before do
      bids(:one).destroy
      visit new_project_bid_path(projects(:one))
    end

    it 'should render the bid form' do
      page.should have_selector('label:contains("'+response_fields(:one).label+'")')
      page.should have_selector('label:contains("'+response_fields(:two).label+'")')
      page.should have_selector('input[type=text][name="response_fields['+response_fields(:one).id.to_s+']"]')
      page.should have_selector('textarea[name="response_fields['+response_fields(:two).id.to_s+']"]')
    end

    it 'should create a bid', js: true do
      page.should have_selector('#save-draft-button.disabled')
      fill_in "response_fields[2]", with: "This is my essay."
      page.should have_selector('#save-draft-button:not(.disabled)')

      # Save Draft
      find("#save-draft-button").click
      page.should have_selector('#save-draft-button.disabled')
      wait_for_ajax
      refresh
      find_field("response_fields[2]").value.should == 'This is my essay.'

      # Trying to submit invalid bid
      click_button "Submit Bid"
      current_path.should == new_project_bid_path(projects(:one))

      # Submit bid
      find_field("response_fields[1]").set 'Yo'
      click_button "Submit Bid"
      page.should have_selector('dd', 'Yo')
      page.should have_selector('dd', 'This is my essay.')
      page.should have_text(projects(:one).form_confirmation_message)
    end
  end

  describe 'bids#show' do
    before do
      visit project_bid_path(projects(:one), bids(:one))
    end

    it 'should show the bid responses' do
      page.should have_selector('dd', responses(:one).value)
      page.should have_selector('dd', responses(:two).value)
    end

    it 'show show the status' do
      page.should have_selector('.badge', text: I18n.t('g.open'))
    end
  end

end