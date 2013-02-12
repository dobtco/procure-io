require 'spec_helper'

describe "Bid" do

  subject { page }

  describe "as vendor" do

    before { login_as(vendors(:one), scope: :vendor) }

    describe "new bid page" do
      before do
        bids(:one).destroy # remove the current bid from this officer
        visit new_project_bid_path(projects(:one))
      end

      it { should have_selector('h4', 'New Bid') }
      it { should have_selector('label', 'Name') }
      it { should have_selector('textarea[name="response_fields[2]"]') }
    end

    describe "saving bid draft", js: true do
      before do
        bids(:one).destroy
        visit new_project_bid_path(projects(:one))
        fill_in "response_fields[1]", with: "Yo"
        fill_in "response_fields[2]", with: "This is my essay."
        expect(page).to have_selector('#save-draft-button:not(.disabled)')
        find("#save-draft-button").click
        expect(page).to have_selector('#save-draft-button.disabled')
        visit new_project_bid_path(projects(:one))
      end

      it "should have the saved values" do
        find_field("response_fields[1]").value.should == 'Yo'
        find_field("response_fields[2]").value.should == 'This is my essay.'
      end
    end
  end
end