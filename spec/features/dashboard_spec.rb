require 'spec_helper'

describe 'Dashboard' do
  it 'should render the current user sidebar section'
  it 'should render a sidebar section for each organization'
  it 'should render a sidebar section for each vendor'

  context 'user is a organization' do
    it 'should display the recent projects'
  end

  context 'user is a vendor' do
    it 'should display the recent bids'
  end

  context 'user has not completed signup' do
    it 'should prompt to create a vendor or organization account'
  end
end
