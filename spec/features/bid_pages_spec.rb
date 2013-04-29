require 'spec_helper'

describe "Bid" do

  subject { page }

  describe "as vendor" do

    before { sign_in(vendors(:one).user) }

    describe "new bid page" do
      before do
        bids(:one).destroy # remove the current bid from this officer
        visit new_project_bid_path(projects(:one))
      end

      it { should have_selector('h4', 'New Bid') }
      it { should have_selector('label', 'Name') }
      it { should have_selector('textarea[name="response_fields[2]"]') }
    end

    describe "response fields" do
      before do
        bids(:one).destroy # remove the current bid from this officer
        visit new_project_bid_path(projects(:one))
      end

      describe "rendering properly" do
        it { should have_selector('label:contains("'+response_fields(:one).label+'")') }
        it { should have_selector('label:contains("'+response_fields(:two).label+'")') }
        it { should have_selector('input[type=text][name="response_fields['+response_fields(:one).id.to_s+']"]') }
        it { should have_selector('textarea[name="response_fields['+response_fields(:two).id.to_s+']"]') }
      end

      describe "validations" do
        pending "haven't yet implemented client-side *or* server-side validations"
      end
    end

    describe "show bid" do
      before do
        visit project_bid_path(projects(:one), bids(:one))
      end

      it { should have_selector('dd', 'Bananas!') }
      it { should have_selector('dd', 'Melons!') }
    end

    describe "create bid", js: true do
      before do
        bids(:one).destroy
        visit new_project_bid_path(projects(:one))
        fill_in "response_fields[1]", with: "Yo"
        fill_in "response_fields[2]", with: "This is my essay."
      end

      it "should save your draft" do
        expect(page).to have_selector('#save-draft-button:not(.disabled)')
        find("#save-draft-button").click
        expect(page).to have_selector('#save-draft-button.disabled')
        visit current_path
        find_field("response_fields[1]").value.should == 'Yo'
        find_field("response_fields[2]").value.should == 'This is my essay.'
      end

      it "should submit bids" do
        click_button "Submit Bid"
        page.should have_selector('dd', 'Yo')
        page.should have_selector('dd', 'This is my essay.')
      end
    end
  end
end