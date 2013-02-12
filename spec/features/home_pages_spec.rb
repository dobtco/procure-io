require 'spec_helper'

describe "Home" do

  fixtures :all

  subject { page }

  describe "root logged out" do
    before { visit root_path }

    it { should have_link('Vendor Login') }
    it { should have_link('Officer Login') }
  end

end