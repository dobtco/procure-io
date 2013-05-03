require 'spec_helper'

describe 'Browsing Projects' do

  before do
    sign_in(vendors(:one).user)
  end

  describe 'projects#index' do
    it 'should save a simple search'
    it 'should save searches by category and filter'
    it 'should search by category when clicking a category'
    it 'should sort by posted_at'
  end

  describe 'projects#show' do
    it 'should only display amendments that are live'
    it 'should display the correct bid button' do
      # when user logged out, no button

      # when user signed in and bids past due
        # if user has a bid
          # show 'your bid' link
        # if user doesnt have a bid
          # nil

      # when user signed in and bids not yet due
        # if user has a bid
          # show 'your bid link'
        # if user has a draft
          # show 'edit draft' link
        # if user doesnt have a bid or a draft'
          # show 'new bid' link
    end
  end


end