require 'spec_helper'

describe "Home" do

  subject { page }

  describe "root logged out" do
    before { visit root_path }

    it { should have_link('Sign in') }
  end

  describe "root logged in" do
    before do
      sign_in(users(:adam_user))
      visit root_path
    end

    it { should have_selector("ul.nav.pull-right", text: officers(:adam).name) }

    describe "it should show email address if user doesnt have a name set" do
      before do
        officers(:adam).update_attributes(name: nil)
        visit root_path
      end
      it { should have_selector("ul.nav.pull-right", text: officers(:adam).user.email) }
    end
  end

end