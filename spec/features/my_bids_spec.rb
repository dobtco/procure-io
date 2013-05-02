require 'spec_helper'

describe 'My Bids' do

  before do
    sign_in(vendors(:one).user)
    visit mine_bids_path
  end

  it 'should render the vendors bids with their statuses' do
    page.should have_selector("a[href=\"#{project_bid_path(projects(:one), bids(:one))}\"]")
    page.should have_selector('.badge', text: I18n.t('g.open'))
  end

  it 'should also show drafts, and link to them properly' do
    projects(:two).bids.create(vendor_id: vendors(:one).id)
    refresh
    page.should have_selector("a[href=\"#{new_project_bid_path(projects(:two))}\"]")
    page.should have_selector('.badge', text: I18n.t('g.draft_saved'))
  end

end